#!/usr/bin/env bash

# Paths
cache_dir="$HOME/.cache/quickshell/weather"
json_file="${cache_dir}/weather.json"
view_file="${cache_dir}/view_id"
daily_cache_file="${cache_dir}/daily_weather_cache.json"
next_day_cache_file="${cache_dir}/next_day_precache.json"
env_tracker_file="${cache_dir}/.env_tracker"
ENV_FILE="$HOME/.config/quickshell/calendar-full/.env"

# API Settings
# Load environment variables silently
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# API Settings from .env
KEY="$OPENWEATHER_KEY"
ID="$OPENWEATHER_CITY_ID"
UNIT="${OPENWEATHER_UNIT:-metric}" # Default to metric if not set

mkdir -p "${cache_dir}"

get_icon() {
    case $1 in
        "50d"|"50n") icon=""; quote="Mist" ;;
        "01d") icon=""; quote="Sunny" ;;
        "01n") icon=""; quote="Clear" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") icon=""; quote="Cloudy" ;;
        "09d"|"09n"|"10d"|"10n") icon=""; quote="Rainy" ;;
        "11d"|"11n") icon=""; quote="Storm" ;;
        "13d"|"13n") icon=""; quote="Snow" ;;
        *) icon=""; quote="Unknown" ;;
    esac
    echo "$icon|$quote"
}

get_hex() {
    case $1 in
        "50d"|"50n") echo "#84afdb" ;;
        "01d") echo "#f9e2af" ;;
        "01n") echo "#cba6f7" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "#bac2de" ;;
        "09d"|"09n"|"10d"|"10n") echo "#74c7ec" ;;
        "11d"|"11n") echo "#f9e2af" ;;
        "13d"|"13n") echo "#cdd6f4" ;;
        *) echo "#cdd6f4" ;;
    esac
}

write_dummy_data() {
    local msg="${1:-No API Key}"

    # Build forecast array using jq for safe JSON construction
    local forecast_array=$(jq -n '[]')

    for i in {0..4}; do
        future_date=$(date -u +%Y-%m-%d -d "+$i days")
        f_day=$(date -u -d "$future_date" "+%a" 2>/dev/null)
        f_full_day=$(date -u -d "$future_date" "+%A" 2>/dev/null)
        f_date_num=$(date -u -d "$future_date" "+%d %b" 2>/dev/null)

        # Create hourly entry safely
        hourly_entry=$(jq -n '{time: "00:00", temp: "0.0", icon: "", hex: "#cdd6f4"}')

        # Create day entry with all fields properly quoted and escaped
        day_entry=$(jq -n \
            --arg id "$i" \
            --arg day "$f_day" \
            --arg day_full "$f_full_day" \
            --arg date "$f_date_num" \
            --arg desc "$msg" \
            --argjson hourly "[$hourly_entry]" \
            '{
                id: $id,
                day: $day,
                day_full: $day_full,
                date: $date,
                max: "0.0",
                min: "0.0",
                feels_like: "0.0",
                wind: "0",
                humidity: "0",
                pop: "0",
                icon: "",
                hex: "#cdd6f4",
                desc: $desc,
                hourly: $hourly
            }')

        # Append to array
        forecast_array=$(echo "$forecast_array" | jq --argjson entry "$day_entry" '. += [$entry]')
    done

    # Create final JSON with forecast array
    final_json=$(echo "$forecast_array" | jq -n --slurpfile forecast /dev/stdin '{forecast: $forecast[0]}')

    echo "$final_json" > "${json_file}.tmp"
    mv "${json_file}.tmp" "${json_file}"
}

get_data() {
    # ---------------------------------------------------------
    # DUMMY DATA FALLBACK (If API key is missing or skipped)
    # ---------------------------------------------------------
    if [[ -z "$KEY" || "$KEY" == "Skipped" || "$KEY" == "OPENWEATHER_KEY" ]]; then
        write_dummy_data "No API Key"
        return
    fi

    # ---------------------------------------------------------
    # STANDARD API FETCH LOGIC
    # Use a curl config file to avoid exposing API key in process listing
    # ---------------------------------------------------------
    local curl_config=$(mktemp)
    trap "rm -f '$curl_config'" RETURN

    cat > "$curl_config" <<EOF
url = "https://api.openweathermap.org/data/2.5/forecast?APPID=${KEY}&id=${ID}&units=${UNIT}"
silent
show-error
fail
EOF

    raw_api=$(curl -K "$curl_config" 2>/dev/null)

    # Check if curl failed OR if OpenWeather returned an error (like 401 for pending keys)
    api_cod=$(echo "$raw_api" | jq -r '.cod' 2>/dev/null)

    if [ -z "$raw_api" ] || [[ "$api_cod" != "200" ]]; then
        if [[ "$api_cod" == "401" ]]; then
            write_dummy_data "Invalid Key"
        else
            write_dummy_data "API Error"
        fi
        return
    fi

    current_date=$(date +%Y-%m-%d)
    tomorrow_date=$(date -d "tomorrow" +%Y-%m-%d)

    # 1. ROLLOVER CHECK
    if [ -f "$next_day_cache_file" ]; then
        precache_date=$(cat "$next_day_cache_file" | jq -r '.[0].dt_txt' | cut -d' ' -f1)
        if [ "$precache_date" == "$current_date" ]; then
            mv "$next_day_cache_file" "$daily_cache_file"
        fi
    fi

    # 2. PROCESS TODAY
    api_today_items=$(echo "$raw_api" | jq -c --arg date "$current_date" ".list[] | select(.dt_txt | startswith(\$date))" | jq -s '.')

    if [ -f "$daily_cache_file" ]; then
        cached_date=$(cat "$daily_cache_file" | jq -r '.[0].dt_txt' | cut -d' ' -f1)
        if [ "$cached_date" == "$current_date" ]; then
            merged_today=$(echo "$api_today_items" | jq --slurpfile cache "$daily_cache_file" \
                '($cache[0] + .) | unique_by(.dt) | sort_by(.dt)')
        else
            merged_today="$api_today_items"
        fi
    else
        merged_today="$api_today_items"
    fi

    echo "$merged_today" > "$daily_cache_file"

    # 3. PRE-CACHE TOMORROW
    api_tomorrow_items=$(echo "$raw_api" | jq -c --arg date "$tomorrow_date" ".list[] | select(.dt_txt | startswith(\$date))" | jq -s '.')
    echo "$api_tomorrow_items" > "$next_day_cache_file"

    # 4. BUILD FINAL JSON
    processed_forecast=$(echo "$raw_api" | jq --argjson today "$merged_today" --arg date "$current_date" \
        '.list = ($today + [.list[] | select(.dt_txt | startswith($date) | not)])')

    if [ ! -z "$processed_forecast" ]; then
        dates=$(echo "$processed_forecast" | jq -r '.list[].dt_txt | split(" ")[0]' | uniq | head -n 5)

        local forecast_array=$(jq -n '[]')
        counter=0

        for d in $dates; do
            day_data=$(echo "$processed_forecast" | jq --arg date "$d" "[.list[] | select(.dt_txt | startswith(\$date))]")

            raw_max=$(echo "$day_data" | jq '[.[].main.temp_max] | max')
            f_max_temp=$(printf "%.1f" "$raw_max")

            raw_min=$(echo "$day_data" | jq '[.[].main.temp_min] | min')
            f_min_temp=$(printf "%.1f" "$raw_min")

            raw_feels=$(echo "$day_data" | jq '[.[].main.feels_like] | max')
            f_feels_like=$(printf "%.1f" "$raw_feels")

            f_pop=$(echo "$day_data" | jq '[.[].pop] | max')
            f_pop_pct=$(printf "%.0f" "$(echo "$f_pop * 100" | bc)")
            f_wind=$(echo "$day_data" | jq '[.[].wind.speed] | max | round')
            f_hum=$(echo "$day_data" | jq '[.[].main.humidity] | add / length | round')

            f_code=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].icon')
            f_desc=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].description' | sed -e "s/\b\(.\)/\u\1/g")
            f_icon_data=$(get_icon "$f_code")
            f_icon=$(echo "$f_icon_data" | cut -d'|' -f1)
            f_hex=$(get_hex "$f_code")
            f_day=$(date -u -d "$d" "+%a" 2>/dev/null)
            f_full_day=$(date -u -d "$d" "+%A" 2>/dev/null)
            f_date_num=$(date -u -d "$d" "+%d %b" 2>/dev/null)

            # Build hourly data using jq
            hourly_json=$(echo "$day_data" | jq -n --slurpfile data /dev/stdin '[
                $data[0][] |
                {
                    time: (.dt | todate | split("T")[1] | .[0:5]),
                    temp: (.main.temp | tostring),
                    icon: (.weather[0].icon),
                    hex: (.weather[0].icon as $code |
                        if $code == "50d" or $code == "50n" then "#84afdb"
                        elif $code == "01d" then "#f9e2af"
                        elif $code == "01n" then "#cba6f7"
                        elif $code == "02d" or $code == "02n" or $code == "03d" or $code == "03n" or $code == "04d" or $code == "04n" then "#bac2de"
                        elif $code == "09d" or $code == "09n" or $code == "10d" or $code == "10n" then "#74c7ec"
                        elif $code == "11d" or $code == "11n" then "#f9e2af"
                        elif $code == "13d" or $code == "13n" then "#cdd6f4"
                        else "#cdd6f4"
                        end
                    )
                }
            ]')

            # Create day entry safely with jq
            day_entry=$(jq -n \
                --arg id "$counter" \
                --arg day "$f_day" \
                --arg day_full "$f_full_day" \
                --arg date "$f_date_num" \
                --arg max "$f_max_temp" \
                --arg min "$f_min_temp" \
                --arg feels_like "$f_feels_like" \
                --arg wind "$f_wind" \
                --arg humidity "$f_hum" \
                --arg pop "$f_pop_pct" \
                --arg icon "$f_icon" \
                --arg hex "$f_hex" \
                --arg desc "$f_desc" \
                --argjson hourly "$hourly_json" \
                '{
                    id: $id,
                    day: $day,
                    day_full: $day_full,
                    date: $date,
                    max: $max,
                    min: $min,
                    feels_like: $feels_like,
                    wind: $wind,
                    humidity: $humidity,
                    pop: $pop,
                    icon: $icon,
                    hex: $hex,
                    desc: $desc,
                    hourly: $hourly
                }')

            forecast_array=$(echo "$forecast_array" | jq --argjson entry "$day_entry" '. += [$entry]')
            ((counter++))
        done

        # Create final JSON with properly escaped forecast
        final_json=$(echo "$forecast_array" | jq -n --slurpfile forecast /dev/stdin '{forecast: $forecast[0]}')

        echo "$final_json" > "${json_file}.tmp"
        mv "${json_file}.tmp" "${json_file}"
    fi
}

# --- MODE HANDLING ---
if [[ "$1" == "--getdata" ]]; then
    get_data

elif [[ "$1" == "--json" ]]; then
    CACHE_LIMIT=900         # 15 minutes for valid working data
    PENDING_RETRY_LIMIT=3600 # 1 hour for invalid/activating keys

    # Check if .env file has been modified since we last checked
    env_changed=0
    if [ -f "$ENV_FILE" ]; then
        env_mtime=$(stat -c %Y "$ENV_FILE")
        last_env_mtime=$(cat "$env_tracker_file" 2>/dev/null || echo "0")

        if [ "$env_mtime" -gt "$last_env_mtime" ]; then
            env_changed=1
            echo "$env_mtime" > "$env_tracker_file"
        fi
    fi

    if [ -f "$json_file" ]; then
        file_time=$(stat -c %Y "$json_file")
        current_time=$(date +%s)
        diff=$((current_time - file_time))

        if [ "$env_changed" -eq 1 ]; then
            # The user just modified the .env file. Bypass cache entirely.
            touch "$json_file"
            get_data &
        elif grep -qE '"desc": "(No API Key|Invalid Key|API Error)"' "$json_file"; then
            # Error state. Check every 5 minutes instead of 1 hour.
            if [ $diff -gt 300 ]; then
                touch "$json_file"
                get_data &
            fi
        else
            # Normal working API key. Check every 15 mins.
            if [ $diff -gt $CACHE_LIMIT ]; then
                touch "$json_file"
                get_data &
            fi
        fi
        cat "$json_file"
    else
        get_data
        cat "$json_file"
    fi

elif [[ "$1" == "--view-listener" ]]; then
    if [ ! -f "$view_file" ]; then echo "0" > "$view_file"; fi
    tail -F "$view_file"

elif [[ "$1" == "--nav" ]]; then
    if [ ! -f "$view_file" ]; then echo "0" > "$view_file"; fi
    current=$(cat "$view_file")
    direction=$2
    max_idx=4
    if [[ "$direction" == "next" ]]; then
        if [ "$current" -lt "$max_idx" ]; then
            new=$((current + 1))
            echo "$new" > "$view_file"
        fi
    elif [[ "$direction" == "prev" ]]; then
        if [ "$current" -gt 0 ]; then
            new=$((current - 1))
            echo "$new" > "$view_file"
        fi
    fi

elif [[ "$1" == "--icon" ]]; then
    cat "$json_file" | jq -r '.forecast[0].icon'

elif [[ "$1" == "--temp" ]]; then
    t=$(cat "$json_file" | jq -r '.forecast[0].max')
    echo "${t}°C"

elif [[ "$1" == "--hex" ]]; then
    cat "$json_file" | jq -r '.forecast[0].hex'

# --- NEW HOURLY MODES FOR TOPBAR ---
elif [[ "$1" == "--current-icon" ]]; then
    curr_time=$(date +%H:%M)
    cat "$json_file" | jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .icon'

elif [[ "$1" == "--current-temp" ]]; then
    curr_time=$(date +%H:%M)
    t=$(cat "$json_file" | jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .temp')
    echo "${t}°C"

elif [[ "$1" == "--current-hex" ]]; then
    curr_time=$(date +%H:%M)
    cat "$json_file" | jq -r --arg ct "$curr_time" '(.forecast[0].hourly | map(select(.time <= $ct)) | last) // .forecast[0].hourly[0] | .hex'
fi
