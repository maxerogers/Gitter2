#config.ru

#Max Rogers Dec 18 2014
#Gitter 2.0

#load in Gemfile
require 'bundler/setup'
Bundler.require
require_all 'config'
require_all 'models'

configure do
  set :server, 'thin'
  enable :sessions
  set :session_secret, "My session secret"
  use Rack::Session::Cookie
  use OmniAuth::Builder do
    #I know this bad form but I haven't deployed yet. So Shhhhhhhh
    provider :twitter, 'p2xojaAqxCshYaAraH4otANCr', 'TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ'
    provider :github, '5394720ddae7b4107128', '17ce0361111c4eaf2746e89de451aa0bc804951a'
  end
  $twitter_bot = Twitter::REST::Client.new do |config|
    config.consumer_key        = "p2xojaAqxCshYaAraH4otANCr"
    config.consumer_secret     = "TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ"
    config.access_token        = "2391713136-Plaxgd57076XBXN4F9Cq3SfR3bxj6o1ZlZEICAS"
    config.access_token_secret = "WYKbsT8HyIt4pC38Y8ggo3tT1EYe0Fq7ZVfrTtsxZYubA"
  end
end

helpers do
  # define a current_user method, so we can be sure if an user is authenticated
  def current_user
    !session[:uid].nil?
  end
end

#Twitter Stuff

get '/auth/twitter/callback' do
  session[:username] = env['omniauth.auth']['info']['name']
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "p2xojaAqxCshYaAraH4otANCr"
    config.consumer_secret     = "TKzK7CRkr71oLRa102V6DF5VQY5BAltvqrkHZWxhXouybcNAxZ"
    config.access_token        = env['omniauth.auth'][:credentials][:token]
    config.access_token_secret = env['omniauth.auth'][:credentials][:secret]
  end
  client.update("I'm tweeting with @gem!")
  $twiitter_bot = client
  "#{env['omniauth.auth']}<br><br>#{env['omniauth.auth'][:credentials][:token]}<br>#{env['omniauth.auth'][:credentials][:secret]}<br>#{env['omniauth.auth'][:uid]}"
end

get '/auth/failure' do
  params[:message]
end


# Sign in
get '/' do
  erb :index
end

run Sinatra::Application
