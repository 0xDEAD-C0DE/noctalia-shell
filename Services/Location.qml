import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
pragma Singleton

// Weather logic and caching
Singleton {
  id: root

  property string locationFile: Quickshell.env("NOCTALIA_WEATHER_FILE") || (Settings.cacheDir + "location.json")
  property int weatherUpdateFrequency: 30 * 60 // 30 minutes expressed in seconds
  property var data: adapter // Used to access via Location.data.xxx
  property bool isFetchingWeather: false

  FileView {
    path: locationFile
    onAdapterUpdated: writeAdapter()
    onLoaded: function () {
      updateWeather()
    }
    onLoadFailed: function (error) {
      updateWeather()
    }

    JsonAdapter {
      id: adapter

      property string latitude: ""
      property string longitude: ""
      property string name: ""
      property int weatherLastFetch: 0
      property var weather: null
    }
  }

  // Every 20s check if we need to fetch new weather
  Timer {
    id: updateTimer
    interval: 20 * 1000
    running: true
    repeat: true
    onTriggered: {
      updateWeather()
    }
  }

  // --------------------------------
  function init() {
    // does nothing but ensure the singleton is created
    // do not remove
    console.log("[Location] Service started")
  }

  // --------------------------------
  function resetWeather() {
    console.log("[Location] Resetting weather data")

    data.latitude = ""
    data.longitude = ""
    data.name = ""
    data.weatherLastFetch = 0
    data.weather = null

    // Try to fetch immediately
    updateWeather()
  }

  // --------------------------------
  function updateWeather() {
    if (isFetchingWeather) {
      console.warn("[Location] Weather is still fetching")
      return
    }

    if (data.latitude === "") {
      console.warn("[Location] Why is my latitude empty")
    }

    if ((data.weatherLastFetch === "") || (data.weather === null) || (data.latitude === "") || (data.longitude === "")
        || (data.name !== Settings.data.location.name)
        || (Time.timestamp >= data.weatherLastFetch + weatherUpdateFrequency)) {
      getFreshWeather()
    }
  }

  // --------------------------------
  function getFreshWeather() {
    isFetchingWeather = true
    if ((data.latitude === "") || (data.longitude === "") || (data.name !== Settings.data.location.name)) {

      _geocodeLocation(Settings.data.location.name, function (latitude, longitude) {
        console.log("[Location] Geocoded " + Settings.data.location.name + " to: " + latitude + " / " + longitude)

        // Save location name
        data.name = Settings.data.location.name

        // Save GPS coordinates
        data.latitude = latitude.toString()
        data.longitude = longitude.toString()

        _fetchWeather(latitude, longitude, errorCallback)
      }, errorCallback)
    } else {
      _fetchWeather(data.latitude, data.longitude, errorCallback)
    }
  }

  // --------------------------------
  function _geocodeLocation(locationName, callback, errorCallback) {
    console.log("[Location] Geocoding from api.open-meteo.com")
    var geoUrl = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(
          locationName) + "&language=en&format=json"
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          try {
            var geoData = JSON.parse(xhr.responseText)
            // console.log(JSON.stringify(geoData))
            if (geoData.results && geoData.results.length > 0) {
              callback(geoData.results[0].latitude, geoData.results[0].longitude)
            } else {
              errorCallback("[Location] could not resolve location name")
            }
          } catch (e) {
            errorCallback("[Location] Failed to parse geocoding data: " + e)
          }
        } else {
          errorCallback("[Location] Geocoding error: " + xhr.status)
        }
      }
    }
    xhr.open("GET", geoUrl)
    xhr.send()
  }

  // --------------------------------
  function _fetchWeather(latitude, longitude, errorCallback) {
    console.log("[Location] Fetching weather from api.open-meteo.com")
    var url = "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude
        + "&current_weather=true&current=relativehumidity_2m,surface_pressure&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto"
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
      if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          try {
            var weatherData = JSON.parse(xhr.responseText)

            // Save data
            data.weather = weatherData
            data.weatherLastFetch = Time.timestamp
            data.latitude = weatherData.latitude.toString()
            data.longitude = weatherData.longitude.toString()

            isFetchingWeather = false
            console.log("[Location] Cached weather to disk")
          } catch (e) {
            errorCallback("[Location] Failed to parse weather data")
          }
        } else {
          errorCallback("[Location] Weather fetch error: " + xhr.status)
        }
      }
    }
    xhr.open("GET", url)
    xhr.send()
  }

  // --------------------------------
  function errorCallback(message) {
    console.error(message)
    isFetchingWeather = false
  }

  // --------------------------------
  function weatherSymbolFromCode(code) {
    if (code === 0)
      return "sunny"
    if (code === 1 || code === 2)
      return "partly_cloudy_day"
    if (code === 3)
      return "cloud"
    if (code >= 45 && code <= 48)
      return "foggy"
    if (code >= 51 && code <= 67)
      return "rainy"
    if (code >= 71 && code <= 77)
      return "weather_snowy"
    if (code >= 80 && code <= 82)
      return "rainy"
    if (code >= 95 && code <= 99)
      return "thunderstorm"
    return "cloud"
  }

  // --------------------------------
  function weatherDescriptionFromCode(code) {
    if (code === 0)
      return "Clear sky"
    if (code === 1)
      return "Mainly clear"
    if (code === 2)
      return "Partly cloudy"
    if (code === 3)
      return "Overcast"
    if (code === 45 || code === 48)
      return "Fog"
    if (code >= 51 && code <= 67)
      return "Drizzle"
    if (code >= 71 && code <= 77)
      return "Snow"
    if (code >= 80 && code <= 82)
      return "Rain showers"
    if (code >= 95 && code <= 99)
      return "Thunderstorm"
    return "Unknown"
  }

  // --------------------------------
  function celsiusToFahrenheit(celsius) {
    return 32 + celsius * 1.8
  }
}
