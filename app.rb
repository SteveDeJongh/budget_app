# app.rb Budget App #

require 'sinatra'
require 'tilt/erubis'

configure do
  enable :sessions
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
end

require_relative "database_persistence"
require_relative "expense"

before do
  @storage = Databasepersistence.new
end

after do
  @storage.disconnect
end

get '/' do
  erb :home, layout: :layout
end