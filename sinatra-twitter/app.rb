require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'haml'

require 'sinatra'
require "sinatra/reloader" if development?

class Twitter < Sinatra::Application
  enable :sessions
end

require_relative 'models/init'
require_relative 'routes/init'
