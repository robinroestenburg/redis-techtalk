require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'haml'
require 'sinatra'
require 'sinatra/reloader'

def redis
  @redis ||= Redis.new(:host => '127.0.0.1', :port => 6379)
end

require_relative 'models/user'
require_relative 'models/post'
require_relative 'routes/authentication'

class Twitter < Sinatra::Application
  use TwitterAuth

  configure :development do
    register Sinatra::Reloader
    also_reload 'models/user.rb'
    also_reload 'models/post.rb'
    also_reload 'routes/authentication.rb'
  end

  enable :sessions

  get '/' do

    @user = current_user

    ## haal gegevens over gebruiker op
    ## TODO
    @number_of_followees = 178
    @number_of_followers = 77

    # Timeline van huidige gebruiker
    @tweets = @user.timeline
    @users  = User.all

    haml :index
  end


  post '/post' do
    if params[:content].length == 0
      @posting_error = "You didn't enter anything."
    elsif params[:content].length > 140
      @posting_error = "Keep it to 140 characters please!"
    end

    if @posting_error

      @user = current_user

      ## haal gegevens over gebruiker op
      ## TODO
      @number_of_followees = 178
      @number_of_followers = 77

      @tweets = @user.timeline
      @users  = User.all

      haml :index

    else
      Post.create(params[:content], current_user)
      redirect '/'
    end

  end

  #
  # Following and unfollowing.
  #
  get '/:follower/follow/:followee' do |follower_username, followee_username|
    follower = User.find_by_username(follower_username)
    followee = User.find_by_username(followee_username)

    follower.follow(followee)

    redirect "/" + followee_username
  end

  get '/:follower/unfollow/:followee' do |follower_username, followee_username|
    follower = User.find_by_username(follower_username)
    followee = User.find_by_username(followee_username)

    follower.unfollow(followee)

    redirect "/" + followee_username
  end

  #
  # Profile page (tweets, followers and following).
  #
  get '/:username' do |username|
    if @user = User.find_by_username(username)
      @tweets = @user.posts
      @users  = User.all
      haml :tweets, :layout => :profile
    else
      redirect "/"
    end
  end

  get '/:username/followers' do |username|
    @user      = User.find_by_username(username)
    @followers = @user.followers
    haml :followers, :layout => :profile
  end

  get '/:username/following' do |username|
    @user      = User.find_by_username(username)
    @followees = @user.followees
    haml :following, :layout => :profile
  end

  private

  def current_user
    User.find(session['user_id'])
  end

end

module Sinatra

  module TimeAgo

    def time_ago_in_words(time)
      distance_in_seconds = (Time.now - time).round

      case distance_in_seconds
      when 0..10
        return "just now"
      when 10..60
        return "less than a minute ago"
      end
      distance_in_minutes = (distance_in_seconds/60).round
      case distance_in_minutes
      when 0..1
        return "a minute ago"
      when 2..45
        return distance_in_minutes.round.to_s + " minutes ago"
      when 46..89
        return "about an hour ago"
      when 90..1439
        return (distance_in_minutes/60).round.to_s + " hours ago"
      when 1440..2879
        return "about a day ago"
      when 2880..43199
        (distance_in_minutes / 1440).round.to_s + " days ago"
      when 43200..86399
        "about a month ago"
      when 86400..525599
        (distance_in_minutes / 43200).round.to_s + " months ago"
      when 525600..1051199
        "about a year ago"
      else
        "over " + (distance_in_minutes / 525600).round.to_s + " years ago"
      end
    end
  end

  helpers TimeAgo
end
