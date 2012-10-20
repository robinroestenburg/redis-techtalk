require_relative '../models/user'

class TwitterAuth < Sinatra::Application

  before do
    unless %w(/login /signup).include?(request.path_info) || request.path_info =~ /\.css$/ || @current_user = User.find(session["user_id"])
      redirect '/login', 303
    end
  end

  get '/login' do
    haml :login, :layout => false
  end

  post '/login' do
    if user = User.find_by_username(params[:username]) && User.hashes_password(user.salt, params[:password]) == user.hashed_password
      session["user_id"] = user.id
      redirect '/'
    else
      @login_error = "Incorrect username or password"
      haml :login, :layout => false
    end
  end

  post '/signup' do
    if params[:username] !~ /^\w+$/
      @signup_error = "Username must only contain letters, numbers and underscores."
    elsif redis.exists("user:username:#{params[:username]}")
      @signup_error = "That username is taken."
    elsif params[:username].length < 4
      @signup_error = "Username must be at least 4 characters"
    elsif params[:password].length < 6
      @signup_error = "Password must be at least 6 characters!"
    elsif params[:password] != params[:password_confirmation]
      @signup_error = "Passwords do not match!"
    end
    if @signup_error
      haml :login, :layout => false
    else
      user = User.create(params[:username], params[:password], params[:emailaddress], params[:fullname])
      session["user_id"] = user.id
      redirect "/"
    end
  end

  get '/logout' do
    session["user_id"] = nil
    redirect '/login'
  end

end
