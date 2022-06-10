class WeatherUtils {
  static int kelvinToCelcius(double kelvin) {
    return (kelvin - 273.15).round();
  }

  static String getWeatherIcon(int kelvin) {
    if (kelvin < 300) {
      return '☁';
    } else if (kelvin < 400) {
      return '🌧';
    } else if (kelvin < 600) {
      return '☔️';
    } else if (kelvin < 700) {
      return '☃️';
    } else if (kelvin < 800) {
      return '🌫';
    } else if (kelvin == 800) {
      return '☀️';
    } else if (kelvin <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  static String getDescription(int temp) {
    if (temp > 25) {
      return 'Бал муздак жесениз болот 🍦 time';
    } else if (temp > 20) {
      return 'Женил кийинип алсаныз болот 👕';
    } else if (temp < 10) {
      return 'жылуу кийининиз кун суук 🧣 жана 🧤';
    } else {
      return 'Жылуу 🧥 куртка кийип алыныз';
    }
  }
}