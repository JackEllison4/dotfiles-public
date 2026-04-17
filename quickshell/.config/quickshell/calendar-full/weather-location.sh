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
    export $(grep -v '^#' "$ENV_FILE" | xargs)
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
        "50d"|"50n") echo "" ;;
        "01d") echo "" ;;
        "01n") echo "" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "" ;;
        "09d"|"09n"|"10d"|"10n") echo "" ;;
        "11d"|"11n") echo "" ;;
        "13d"|"13n") echo "" ;;
        *) echo "" ;;
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
    final_json="["
    for i in {0..4}; do
        future_date=$(date -u +%Y-%m-%d -d "+$i days")
        f_day=$(date -u -d "$future_date" "+%a" 2>/dev/null)
        f_full_day=$(date -u -d "$future_date" "+%A" 2>/dev/null)
        f_date_num=$(date -u -d "$future_date" "+%d %b" 2>/dev/null)

        final_json="${final_json} {
            \"id\": \"${i}\",
            \"day\": \"${f_day}\",
            \"day_full\": \"${f_full_day}\",
            \"date\": \"${f_date_num}\",
            \"max\": \"0.0\",
            \"min\": \"0.0\",
            \"feels_like\": \"0.0\",
            \"wind\": \"0\",
            \"humidity\": \"0\",
            \"pop\": \"0\",
            \"icon\": \"\",
            \"hex\": \"#a6adc8\",
            \"desc\": \"${msg}\",
            \"hourly\": [{\"time\": \"00:00\", \"temp\": \"0.0\", \"icon\": \"\", \"hex\": \"#a6adc8\"}]
        },"
    done
    final_json="${final_json%,}]"
    echo "{ \"location\": \"Unknown\", \"forecast\": ${final_json} }" > "${json_file}"
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

    # Fetch weather data using lat/lon
    forecast_url="https://api.openweathermap.org/data/2.5/forecast?appid=${KEY}&lat=${lat}&lon=${lon}&units=${UNIT}"
    raw_api=$(curl -sf "$forecast_url")

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

        final_json="["
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
            f_pop_pct=$(echo "$f_pop * 100" | bc 2>/dev/null | cut -d. -f1)

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

            hourly_json="["
            count_slots=$(echo "$day_data" | jq '. | length')

            for i in $(seq 0 1 $((count_slots-1))); do
                slot_item=$(echo "$day_data" | jq ".[$i]")

                s_temp=$(echo "$slot_item" | jq ".main.temp" | xargs printf "%.0f")
                s_dt=$(echo "$slot_item" | jq ".dt")
                s_time=$(date -d @$s_dt "+%H:%M" 2>/dev/null)
                s_code=$(echo "$slot_item" | jq -r ".weather[0].icon")
                s_hex=$(get_hex "$s_code")
                s_icon=$(get_icon "$s_code")

                hourly_json="${hourly_json} {\"time\": \"${s_time}\", \"temp\": \"${s_temp}\", \"icon\": \"${s_icon}\", \"hex\": \"${s_hex}\"},"
            done
            hourly_json="${hourly_json%,}]"

            final_json="${final_json} {
                \"id\": \"${counter}\",
                \"day\": \"${f_day}\",
                \"day_full\": \"${f_full_day}\",
                \"date\": \"${f_date_num}\",
                \"max\": \"${f_max_temp}\",
                \"min\": \"${f_min_temp}\",
                \"feels_like\": \"${f_feels_like}\",
                \"wind\": \"${f_wind}\",
                \"humidity\": \"${f_hum}\",
                \"pop\": \"${f_pop_pct}\",
                \"icon\": \"${f_icon}\",
                \"hex\": \"${f_hex}\",
                \"desc\": \"${f_desc}\",
                \"hourly\": ${hourly_json}
            },"

            counter=$((counter+1))
        done

        final_json="${final_json%,}]"

        echo "{ \"location\": \"${city_name}\", \"forecast\": ${final_json} }" > "${json_file}"
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
