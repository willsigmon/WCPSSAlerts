import Foundation
import WeatherKit
import CoreLocation

@MainActor
public final class WeatherService {
    private let weatherService = WeatherKit.WeatherService.shared

    // Raleigh, NC coordinates
    private let defaultLocation = CLLocation(latitude: 35.7796, longitude: -78.6382)

    // MARK: - Current Weather
    func fetchCurrentWeather(for location: CLLocation? = nil) async throws -> CurrentWeather {
        let loc = location ?? defaultLocation
        let weather = try await weatherService.weather(for: loc)

        return CurrentWeather(
            temperature: weather.currentWeather.temperature.value,
            temperatureUnit: "F",
            condition: weather.currentWeather.condition.description,
            conditionSymbol: weather.currentWeather.symbolName,
            humidity: weather.currentWeather.humidity * 100,
            windSpeed: weather.currentWeather.wind.speed.value,
            windDirection: weather.currentWeather.wind.direction.value,
            visibility: weather.currentWeather.visibility.value,
            precipitationChance: weather.hourlyForecast.first?.precipitationChance ?? 0
        )
    }

    // MARK: - Forecast
    func fetchHourlyForecast(for location: CLLocation? = nil, hours: Int = 24) async throws -> [HourlyForecast] {
        let loc = location ?? defaultLocation
        let weather = try await weatherService.weather(for: loc)

        return weather.hourlyForecast.prefix(hours).map { hour in
            HourlyForecast(
                date: hour.date,
                temperature: hour.temperature.value,
                condition: hour.condition.description,
                conditionSymbol: hour.symbolName,
                precipitationChance: hour.precipitationChance,
                snowfallAmount: hour.snowfallAmount.value
            )
        }
    }
}

// MARK: - Models
struct CurrentWeather: Sendable {
    let temperature: Double
    let temperatureUnit: String
    let condition: String
    let conditionSymbol: String
    let humidity: Double
    let windSpeed: Double
    let windDirection: Double
    let visibility: Double
    let precipitationChance: Double
}

struct HourlyForecast: Identifiable, Sendable {
    var id: Date { date }
    let date: Date
    let temperature: Double
    let condition: String
    let conditionSymbol: String
    let precipitationChance: Double
    let snowfallAmount: Double
}
