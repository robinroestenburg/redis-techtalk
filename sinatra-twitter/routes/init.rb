class Twitter < Sinatra::Application

  get '/' do
    haml :index
  end

end
