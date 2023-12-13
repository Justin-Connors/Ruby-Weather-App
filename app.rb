require 'sinatra'
require 'sinatra/reloader' if development?
require 'httparty'
require 'dotenv/load'
require 'json'
require 'erb'

#add stylesheet
get '/styles.css' do
    content_type 'text/css'
    File.read('./views/styles.css')
end

API_KEY = ENV['API_KEY']

BASE_URL = 'http://api.openweathermap.org/data/2.5/weather'

get '/' do
    erb :index
end

post '/weather' do
    city = params[:city]
    redirect to("/weather/#{city}")
end

get '/weather/:city' do
    city = params[:city]
    @weather_data = fetch_weather(city)
    @forecast_data = fetch_weekly_forecast(city)
    erb :weather
end

def fetch_weather(city)
    response = HTTParty.get("#{BASE_URL}?q=#{city}&appid=#{API_KEY}&units=metric")
    return {} unless response.success?

    puts response.body

    weather_data = JSON.parse(response.body) 
    {
        name: weather_data['name'],
        temperature: weather_data['main']['temp'],
        description: weather_data['weather'][0]['description'],
        feels_like: weather_data['main']['feels_like'],
        humidity: weather_data['main']['humidity'],
        visibility: weather_data['visibility'],
        wind_speed: weather_data['wind']['speed'],
        icon: weather_data['weather'][0]['icon'],
        forecast: fetch_weekly_forecast(city)
    }
end

def fetch_weekly_forecast(city)
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast?q=#{city}&appid=#{API_KEY}&units=metric")
    return [] unless response.success?

    forecast_data = JSON.parse(response.body)
    forecast_data['list'].map do |forecast|
        {
            date: Time.at(forecast['dt']).to_date,
            temperature: forecast['main']['temp'],
            description: forecast['weather'][0]['description'],
            feels_like: forecast['main']['feels_like'],
            humidity: forecast['main']['humidity'],
            visibility: forecast['visibility'],
            wind_speed: forecast['wind']['speed'],
            icon: forecast['weather'][0]['icon']
        }
    end
end

