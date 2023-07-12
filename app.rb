# app.rb Budget App #

require 'sinatra'
require 'tilt/eurbis'

configure(:development) do
  require 'sinatra/reloader'
end