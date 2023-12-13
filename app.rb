require 'sinatra'
require 'sinatra/reloader' if development?
require 'httparty'
require 'dotenv/load'

API_KEY = ENV['API_KEY']

BASE_URL = 'http://api.openweathermap.org/data/2.5/weather'