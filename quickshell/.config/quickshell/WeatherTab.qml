import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool active: false
    
    // OpenWeather icon mapping (weather condition IDs)
    function getOpenWeatherIcon(conditionId) {
        if (conditionId >= 200 && conditionId < 300) return "⛈️" // Thunderstorm
        if (conditionId >= 300 && conditionId < 400) return "🌦️" // Drizzle
        if (conditionId >= 500 && conditionId < 600) return "🌧️" // Rain
        if (conditionId >= 600 && conditionId < 700) return "❄️" // Snow
        if (conditionId >= 700 && conditionId < 800) return "🌫️" // Atmosphere (fog, mist, etc)
        if (conditionId === 800) return "☀️" // Clear
        if (conditionId === 801) return "⛅" // Few clouds
        if (conditionId === 802) return "⛅" // Scattered clouds
        if (conditionId === 803 || conditionId === 804) return "☁️" // Broken/overcast clouds
        return "🌡️" // Default
    }
    
    Column {
        anchors.fill: parent
        spacing: 16
        
        // Current Weather (top half)
        Rectangle {
            width: parent.width
            height: (parent.height - 16) * 0.45
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
            Item {
                anchors.fill: parent
                anchors.margins: 24
                
                // Left: Icon and temp
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -parent.width * 0.25
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16
                    
                    Text {
                        id: currentIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "⛅"
                        font.family: "Noto Color Emoji"
                        font.pixelSize: 80
                    }
                    
                    Text {
                        id: currentTemp
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "..."
                        font.family: "Sen"
                        font.pixelSize: 48
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                    }
                    
                    Text {
                        id: currentCondition
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Loading..."
                        font.family: "Sen"
                        font.pixelSize: 18
                        color: ThemeManager.fgSecondary
                    }
                }
                
                // Right: Details
                Column {
                    width: parent.width * 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: parent.width * 0.25
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20
                    
                    Text {
                        id: cityName
                        text: ""
                        font.family: "Sen"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: ThemeManager.accentBlue
                        width: parent.width
                        elide: Text.ElideRight
                        visible: text !== ""
                    }
                    
                    Text {
                        id: locationText
                        text: "📍 Loading location..."
                        font.family: "Sen"
                        font.pixelSize: 14
                        color: ThemeManager.fgSecondary
                        width: parent.width
                        elide: Text.ElideRight
                    }
                    
                    Grid {
                        columns: 2
                        columnSpacing: 40
                        rowSpacing: 16
                        
                        // Feels Like
                        Column {
                            spacing: 4
                            Text {
                                text: "Feels Like"
                                font.family: "Sen"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: feelsLike
                                text: "--"
                                font.family: "Sen"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                        
                        // Humidity
                        Column {
                            spacing: 4
                            Text {
                                text: "Humidity"
                                font.family: "Sen"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: humidity
                                text: "--"
                                font.family: "Sen"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentCyan
                            }
                        }
                        
                        // Wind Speed
                        Column {
                            spacing: 4
                            Text {
                                text: "Wind Speed"
                                font.family: "Sen"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: windSpeed
                                text: "--"
                                font.family: "Sen"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.accentGreen
                            }
                        }
                        
                        // Pressure
                        Column {
                            spacing: 4
                            Text {
                                text: "Pressure"
                                font.family: "Sen"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                            Text {
                                id: pressure
                                text: "--"
                                font.family: "Sen"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }
                        }
                    }
                }
            }
        }
        
        // 5-Day Forecast (bottom half)
        Rectangle {
            width: parent.width
            height: (parent.height - 16) * 0.55
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            clip: false
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Text {
                        text: "📊"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "3-Day Forecast"
                        font.family: "Sen"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 2
                    color: Qt.rgba(1, 1, 1, 0.10)
                }
                
                // Forecast items
                Row {
                    width: parent.width
                    height: parent.height - 60
                    spacing: 8
                    clip: false

                    Repeater {
                        model: forecastModel.updateCount >= 0 ? Math.min(3, forecastModel.forecast.length) : 0

                        Rectangle {
                            width: (parent.width - (2 * 8)) / 3
                            height: parent.height
                            color: Qt.rgba(1, 1, 1, 0.07)
                            radius: 10
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                
                                Text {
                                    id: dayLabel
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecastModel.getDayLabel(index)
                                    font.family: "Sen"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }
                                
                                Text {
                                    id: forecastIcon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecastModel.getIcon(index)
                                    font.family: "Noto Color Emoji"
                                    font.pixelSize: 40
                                }
                                
                                Column {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: forecastModel.getHighTemp(index)
                                        font.family: "Sen"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: ThemeManager.accentRed
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: forecastModel.getLowTemp(index)
                                        font.family: "Sen"
                                        font.pixelSize: 14
                                        color: ThemeManager.accentCyan
                                    }
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: forecastModel.getCondition(index)
                                    font.family: "Sen"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgSecondary
                                    width: parent.parent.width - 16
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Reverse geocoding to get city name from coordinates
    Process {
        id: reverseGeocodeProcess
        command: ["sh", "-c", "echo"]
        running: false
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { reverseGeocodeProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const data = JSON.parse(buffer)
                    if (data.address) {
                        let parts = []
                        if (data.address.city || data.address.town || data.address.village) {
                            parts.push(data.address.city || data.address.town || data.address.village)
                        }
                        if (data.address.state) {
                            parts.push(data.address.state)
                        }
                        if (data.address.country) {
                            parts.push(data.address.country)
                        }
                        if (parts.length > 0) {
                            cityName.text = "🏙️ " + parts.join(", ")
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse geocoding data:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Weather update timer - delayed start for performance
    Timer {
        id: weatherUpdateTimer
        interval: 300000 // 5 minutes
        running: root.active && hasInitialLoad
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            settingsLoader.running = false
            Qt.callLater(() => {
                settingsLoader.running = true
            })
        }
    }
    
    // Lazy loading: Delay first weather load by 5 seconds
    property bool hasInitialLoad: false
    Timer {
        id: initialLoadTimer
        interval: 100 // Load almost immediately after tab becomes active
        running: root.active && !hasInitialLoad
        repeat: false
        onTriggered: {
            hasInitialLoad = true
            settingsLoader.running = true
        }
    }
    
    // Load weather settings
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { settingsLoader.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    let latitude = ""
                    let longitude = ""
                    let city = ""
                    let state = ""
                    let country = ""
                    let apiKey = ""
                    let useFahrenheit = true
                    
                    if (settings.general) {
                        latitude = settings.general.weatherLatitude || ""
                        longitude = settings.general.weatherLongitude || ""
                        city = settings.general.weatherCity || ""
                        state = settings.general.weatherState || ""
                        country = settings.general.weatherCountry || ""
                        apiKey = settings.general.openWeatherApiKey || ""
                        useFahrenheit = settings.general.useFahrenheit !== false
                    }
                    
                    // Build location name for display
                    let locationName = ""
                    if (city) {
                        locationName = city
                        if (state) locationName += ", " + state
                        if (country) locationName += " " + country
                        cityName.text = "🏙️ " + locationName
                    } else {
                        cityName.text = ""
                    }
                    
                    // Display lat/long coordinates directly
                    if (latitude && longitude) {
                        locationText.text = `📍 ${latitude}, ${longitude}`
                    } else {
                        locationText.text = "📍 No location set"
                    }
                    
                    const tempUnit = useFahrenheit ? "u" : "m"
                    let location = (latitude && longitude) ? `${latitude},${longitude}` : ""
                    
                    // Store useFahrenheit setting for forecast parsing
                    forecastModel.useFahrenheit = useFahrenheit

                    // Use OpenWeather API if key is available, otherwise use wttr.in
                    if (apiKey && latitude && longitude) {
                        const units = useFahrenheit ? "imperial" : "metric"

                        // Safely construct URLs with proper escaping
                        const lat = String(latitude).replace(/[^0-9.-]/g, "")
                        const lon = String(longitude).replace(/[^0-9.-]/g, "")
                        const unit = String(units).replace(/[^a-z]/g, "")
                        const key = String(apiKey).replace(/[^a-zA-Z0-9]/g, "")

                        // Current weather with OpenWeather - use argument array, not sh -c
                        openWeatherProcess.command = ["curl", "-s", "https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&units=" + unit + "&appid=" + key]
                        openWeatherProcess.running = true

                        // 5-day forecast with OpenWeather - use argument array, not sh -c
                        openWeatherForecastProcess.command = ["curl", "-s", "https://api.openweathermap.org/data/2.5/forecast?lat=" + lat + "&lon=" + lon + "&units=" + unit + "&appid=" + key]
                        openWeatherForecastProcess.running = true
                    } else {
                        // Current weather with wttr.in - sanitize location
                        const safeLocation = String(location || "").replace(/[^a-zA-Z0-9,-]/g, "")
                        weatherProcess.command = ["sh", "-c", "curl -s 'wttr.in/" + safeLocation + "?" + tempUnit + "&format=%c|%t|%C|%h|%w|%l|%f|%p'"]
                        weatherProcess.running = true

                        // Forecast with wttr.in (3 days)
                        forecastProcess.command = ["sh", "-c", "curl -s 'wttr.in/" + safeLocation + "?" + tempUnit + "&format=j1'"]
                        forecastProcess.running = true
                    }
                } catch (e) {
                    console.error("Failed to parse settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Fetch current weather
    Process {
        id: weatherProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=%c|%t|%C|%h|%w|%l|%f|%p'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                console.log("Weather current output:", data);
                const parts = data.trim().split('|')
                if (parts.length >= 7) {
                    currentIcon.text = (parts[0] || "🌡️").trim()
                    let temp = (parts[1] || "N/A").trim()
                    currentTemp.text = temp.replace(/^\+/, "")
                    currentCondition.text = (parts[2] || "Unknown").trim()
                    humidity.text = (parts[3] || "--").trim()
                    windSpeed.text = (parts[4] || "--").trim()
                    // Only set location from API if we don't have city name
                    if (cityName.text === "") {
                        locationText.text = "📍 " + (parts[5] || "Unknown").trim()
                    }
                    feelsLike.text = (parts[6] || "--").trim().replace(/^\+/, "")
                    pressure.text = (parts[7] || "--").trim()
                }
            }
        }
    }
    
    // Fetch forecast
    Process {
        id: forecastProcess
        command: ["sh", "-c", "curl -s 'wttr.in/?u&format=j1'"]
        running: false
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { forecastProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                console.log("Forecast buffer length:", buffer.length);
                try {
                    const data = JSON.parse(buffer)
                    if (data.weather && Array.isArray(data.weather)) {
                        forecastModel.parseForecast(data.weather)
                    } else {
                        console.error("No weather data in forecast response")
                    }
                } catch (e) {
                    console.error("Failed to parse forecast:", e)
                    console.error("Buffer content:", buffer.substring(0, 500))
                }
                buffer = ""
            } else if (running) {
                console.log("Forecast process started");
                buffer = ""
            }
        }
    }
    
    // OpenWeather current weather
    Process {
        id: openWeatherProcess
        command: ["sh", "-c", "echo"]
        running: false
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { openWeatherProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const data = JSON.parse(buffer)

                    if (data.weather && data.weather[0]) {
                        currentIcon.text = getOpenWeatherIcon(data.weather[0].id)
                        currentCondition.text = data.weather[0].description
                    }
                    
                    if (data.main) {
                        const tempSymbol = forecastModel.useFahrenheit ? "°F" : "°C"
                        currentTemp.text = Math.round(data.main.temp) + tempSymbol
                        feelsLike.text = Math.round(data.main.feels_like) + tempSymbol
                        humidity.text = data.main.humidity + "%"
                        pressure.text = data.main.pressure + " hPa"
                    }
                    
                    if (data.wind) {
                        const speedUnit = forecastModel.useFahrenheit ? " mph" : " m/s"
                        windSpeed.text = Math.round(data.wind.speed) + speedUnit
                    }
                } catch (e) {
                    console.error("Failed to parse OpenWeather data:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // OpenWeather 5-day forecast
    Process {
        id: openWeatherForecastProcess
        command: ["sh", "-c", "echo"]
        running: false
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { openWeatherForecastProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const data = JSON.parse(buffer)

                    if (data.list && data.list.length > 0) {
                        forecastModel.parseOpenWeatherForecast(data.list)
                    }
                } catch (e) {
                    console.error("Failed to parse OpenWeather forecast:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Forecast model
    QtObject {
        id: forecastModel
        
        property var forecast: []
        property int updateCount: 0
        
        property bool useFahrenheit: true
        
        function parseForecast(weatherData) {
            forecast = []
            for (let i = 0; i < Math.min(5, weatherData.length); i++) {
                let day = weatherData[i]
                let high = useFahrenheit ? (day.maxtempF + "°F") : (day.maxtempC + "°C")
                let low = useFahrenheit ? (day.mintempF + "°F") : (day.mintempC + "°C")
                forecast.push({
                    date: day.date || "",
                    highTemp: high || "--",
                    lowTemp: low || "--",
                    condition: day.hourly && day.hourly[0] ? day.hourly[0].weatherDesc[0].value : "Unknown",
                    icon: getWeatherIcon(day.hourly && day.hourly[0] ? day.hourly[0].weatherCode : "")
                })
            }
            updateCount++
        }
        
        function getWeatherIcon(code) {
            // Weather icon mapping based on weather codes
            const iconMap = {
                "113": "☀️", "116": "⛅", "119": "☁️", "122": "☁️", "143": "🌫️",
                "176": "🌦️", "179": "🌨️", "182": "🌨️", "185": "🌨️", "200": "⛈️",
                "227": "🌨️", "230": "❄️", "248": "🌫️", "260": "🌫️", "263": "🌦️",
                "266": "🌧️", "281": "🌧️", "284": "🌧️", "293": "🌦️", "296": "🌧️",
                "299": "🌧️", "302": "🌧️", "305": "🌧️", "308": "🌧️", "311": "🌧️",
                "314": "🌧️", "317": "🌧️", "320": "🌨️", "323": "🌨️", "326": "🌨️",
                "329": "❄️", "332": "❄️", "335": "❄️", "338": "❄️", "350": "🌨️",
                "353": "🌦️", "356": "🌧️", "359": "🌧️", "362": "🌨️", "365": "🌨️",
                "368": "🌨️", "371": "❄️", "374": "🌨️", "377": "🌨️", "386": "⛈️",
                "389": "⛈️", "392": "⛈️", "395": "❄️"
            }
            return iconMap[code] || "⛅"
        }
        
        function parseOpenWeatherForecast(forecastList) {
            // OpenWeather provides 3-hour forecasts, group by day
            forecast = []
            const tempSymbol = useFahrenheit ? "°F" : "°C"
            let dailyData = {}
            
            // Group forecasts by date
            for (let i = 0; i < forecastList.length; i++) {
                const item = forecastList[i]
                const dateStr = item.dt_txt.split(' ')[0] // Get date part
                
                if (!dailyData[dateStr]) {
                    dailyData[dateStr] = {
                        date: dateStr,
                        temps: [],
                        conditions: [],
                        icons: []
                    }
                }
                
                dailyData[dateStr].temps.push(item.main.temp)
                if (item.weather && item.weather[0]) {
                    dailyData[dateStr].conditions.push(item.weather[0].description)
                    dailyData[dateStr].icons.push(item.weather[0].id)
                }
            }
            
            // Convert to forecast array (take first 5 days)
            const dates = Object.keys(dailyData).sort().slice(0, 5)
            for (let i = 0; i < dates.length; i++) {
                const day = dailyData[dates[i]]
                const high = Math.max(...day.temps)
                const low = Math.min(...day.temps)
                const mostCommonIcon = day.icons[Math.floor(day.icons.length / 2)] || day.icons[0]
                const condition = day.conditions[Math.floor(day.conditions.length / 2)] || day.conditions[0]
                
                forecast.push({
                    date: day.date,
                    highTemp: Math.round(high) + tempSymbol,
                    lowTemp: Math.round(low) + tempSymbol,
                    condition: condition,
                    icon: getOpenWeatherIcon(mostCommonIcon)
                })
            }
            updateCount++
        }
        
        function getDayLabel(index) {
            if (forecast.length <= index) return "..."
            if (index === 0) return "Today"
            if (index === 1) return "Tomorrow"
            
            const date = new Date()
            date.setDate(date.getDate() + index)
            const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return days[date.getDay()]
        }
        
        function getIcon(index) {
            return forecast.length > index ? forecast[index].icon : "⛅"
        }
        
        function getHighTemp(index) {
            return forecast.length > index ? forecast[index].highTemp : "--"
        }
        
        function getLowTemp(index) {
            return forecast.length > index ? forecast[index].lowTemp : "--"
        }
        
        function getCondition(index) {
            return forecast.length > index ? forecast[index].condition : "..."
        }
    }
}
