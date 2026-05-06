#!/usr/bin/env bash

# Paths
cache_dir="$HOME/.cache/quickshell/weather"
json_file="${cache_dir}/weather.json"
env_tracker_file="${cache_dir}/.env_tracker"
location_file="${cache_dir}/.location"
ENV_FILE="$HOME/.config/quickshell/calendar-full/.env"

# Create cache directory
mkdir -p "${cache_dir}"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# API Settings
KEY="$OPENWEATHER_KEY"
UNIT="${OPENWEATHER_UNIT:-metric}"

# ============================================================
# LOCATION DETECTION
# ============================================================
get_location() {
    # Check if manual location is set in .env
    if [ ! -z "$LOCATION_LAT" ] && [ ! -z "$LOCATION_LON" ]; then
        echo "$LOCATION_LAT,$LOCATION_LON"
        return
    fi

    # Try to get location from IP geolocation (ipapi.co is free and simple)
    location=$(curl -sf "https://ipapi.co/json/" | jq -r '"\(.latitude),\(.longitude)"' 2>/dev/null)

    if [ ! -z "$location" ] && [ "$location" != "null" ]; then
        echo "$location" > "$location_file"
        echo "$location"
    else
        # Fallback: try cached location
        if [ -f "$location_file" ]; then
            cat "$location_file"
        else
            # Default to San Francisco if everything fails
            echo "37.7749,-122.4194"
        fi
    fi
}

# ============================================================
# ICON & COLOR MAPPING
# ============================================================
get_icon() {
    case $1 in
        "50d"|"50n") echo "" ;;
        "01d") echo "" ;;
        "01n") echo "" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "" ;;
        "09d"|"09n"|"10d"|"10n") echo "" ;;
        "11d"|"11n") echo "" ;;
        "13d"|"13n") echo "" ;;
        *) echo "" ;;
    esac
}

get_hex() {
    case $1 in
        "50d"|"50n") echo "#94e2d5" ;;
        "01d") echo "#f9e2af" ;;
        "01n") echo "#cba6f7" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "#a6adc8" ;;
        "09d"|"09n"|"10d"|"10n") echo "#89dceb" ;;
        "11d"|"11n") echo "#f5c2e7" ;;
        "13d"|"13n") echo "#bac2de" ;;
        *) echo "#a6adc8" ;;
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
        hourly_entry=$(jq -n '{time: "00:00", temp: "0.0", icon: "", hex: "#a6adc8"}')

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
                hex: "#a6adc8",
                desc: $desc,
                hourly: $hourly
            }')

        # Append to array
        forecast_array=$(echo "$forecast_array" | jq --argjson entry "$day_entry" '. += [$entry]')
    done

    # Create final JSON with location and forecast
    final_json=$(echo "$forecast_array" | jq -n --slurpfile forecast /dev/stdin '{location: "Unknown", forecast: $forecast[0]}')

    echo "$final_json" > "${json_file}.tmp"
    mv "${json_file}.tmp" "${json_file}"
}

get_data() {
    # Check for API key
    if [[ -z "$KEY" || "$KEY" == "Skipped" || "$KEY" == "OPENWEATHER_KEY" ]]; then
        write_dummy_data "No API Key"
        return
    fi

    # Get location
    location=$(get_location)
    lat=$(echo "$location" | cut -d',' -f1)
    lon=$(echo "$location" | cut -d',' -f2)

    # Fetch weather data using lat/lon with safe curl config
    local curl_config=$(mktemp)
    trap "rm -f '$curl_config'" RETURN

    cat > "$curl_config" <<EOF
url = "https://api.openweathermap.org/data/2.5/forecast?appid=${KEY}&lat=${lat}&lon=${lon}&units=${UNIT}"
silent
show-error
fail
EOF

    raw_api=$(curl -K "$curl_config" 2>/dev/null)

    api_cod=$(echo "$raw_api" | jq -r '.cod' 2>/dev/null)

    if [ -z "$raw_api" ] || [[ "$api_cod" != "200" ]]; then
        if [[ "$api_cod" == "401" ]]; then
            write_dummy_data "Invalid Key"
        else
            write_dummy_data "API Error"
        fi
        return
    fi

    # Process API response (use UTC dates to match API)
    current_date=$(date -u +%Y-%m-%d)
    tomorrow_date=$(date -u -d "tomorrow" +%Y-%m-%d)

    processed_forecast=$(echo "$raw_api" | jq ".list |= [.[] | select(.dt_txt | startswith(\"$current_date\") or startswith(\"$tomorrow_date\") or startswith(\"${current_date:0:7}\"))]")

    if [ ! -z "$processed_forecast" ]; then
        # Extract city name from raw API (try multiple paths)
        city_name=$(echo "$raw_api" | jq -r '.city.name // .name // "Unknown"' 2>/dev/null)

        dates=$(echo "$processed_forecast" | jq -r '.list[].dt_txt | split(" ")[0]' | sort -u | head -n 5)

        local forecast_array=$(jq -n '[]')
        counter=0

        for d in $dates; do
            day_data=$(echo "$processed_forecast" | jq "[.list[] | select(.dt_txt | startswith(\"$d\"))]")

            raw_max=$(echo "$day_data" | jq '[.[].main.temp_max] | max')
            f_max_temp=$(printf "%.0f" "$raw_max")

            raw_min=$(echo "$day_data" | jq '[.[].main.temp_min] | min')
            f_min_temp=$(printf "%.0f" "$raw_min")

            raw_feels=$(echo "$day_data" | jq '[.[].main.feels_like] | add / length')
            f_feels_like=$(printf "%.0f" "$raw_feels")

            f_pop=$(echo "$day_data" | jq '[.[].pop] | max')
            f_pop_pct=$(printf "%.0f" "$(echo "$f_pop * 100" | bc)")

            f_wind=$(echo "$day_data" | jq '[.[].wind.speed] | max' 2>/dev/null | xargs printf "%.0f")
            f_hum=$(echo "$day_data" | jq '[.[].main.humidity] | add / length' 2>/dev/null | xargs printf "%.0f")

            f_code=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].icon')
            f_desc=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].description | ascii_upcase')
            f_icon=$(get_icon "$f_code")
            f_hex=$(get_hex "$f_code")

            # Use UTC date directly from API (don't convert to local)
            f_day=$(date -u -d "$d" "+%a" 2>/dev/null)
            f_full_day=$(date -u -d "$d" "+%A" 2>/dev/null)
            f_date_num=$(date -u -d "$d" "+%d %b" 2>/dev/null)

            # Build hourly data using jq - properly escape all values
            hourly_array=$(echo "$day_data" | jq '[
                .[] |
                {
                    time: (.dt | todate | split("T")[1] | .[0:5]),
                    temp: (.main.temp | floor | tostring),
                    icon: (.weather[0].icon),
                    hex: (.weather[0].icon as $code |
                        if $code == "50d" or $code == "50n" then "#94e2d5"
                        elif $code == "01d" then "#f9e2af"
                        elif $code == "01n" then "#cba6f7"
                        elif $code == "02d" or $code == "02n" or $code == "03d" or $code == "03n" or $code == "04d" or $code == "04n" then "#a6adc8"
                        elif $code == "09d" or $code == "09n" or $code == "10d" or $code == "10n" then "#89dceb"
                        elif $code == "11d" or $code == "11n" then "#f5c2e7"
                        elif $code == "13d" or $code == "13n" then "#bac2de"
                        else "#a6adc8"
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
                --argjson hourly "$hourly_array" \
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

            counter=$((counter+1))
        done

        # Create final JSON with location and forecast
        final_json=$(echo "$forecast_array" | jq -n --slurpfile forecast /dev/stdin --arg city "$city_name" '{location: $city, forecast: $forecast[0]}')

        echo "$final_json" > "${json_file}.tmp"
        mv "${json_file}.tmp" "${json_file}"
    fi
}

if [[ "$1" == "--json" ]]; then
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
else
    # Just fetch new data directly
    get_data
fi
