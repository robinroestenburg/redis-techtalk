require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'haml'
require 'sinatra'
require 'sinatra/reloader'

def redis
  @redis ||= Redis.new(:host => '127.0.0.1', :port => 6379)
end

require_relative 'helpers/time_ago'
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
    @user   = current_user
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

      @user   = current_user
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

    redirect "/"
  end

  get '/:follower/unfollow/:followee' do |follower_username, followee_username|
    follower = User.find_by_username(follower_username)
    followee = User.find_by_username(followee_username)

    follower.unfollow(followee)

    redirect "/"
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
    @users     = User.all
    haml :followers, :layout => :profile
  end

  get '/:username/following' do |username|
    @user      = User.find_by_username(username)
    @followees = @user.followees
    @users     = User.all
    haml :following, :layout => :profile
  end

  private

  def current_user
    User.find(session['user_id'])
  end

end
