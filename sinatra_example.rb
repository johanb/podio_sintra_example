require 'rubygems'
require 'sinatra'
require 'oauth2'
require 'json'

def podio_client
  client_id = 'YOUR_CLIENT_ID'
  client_secret = 'YOUR_CLIENT_SECRET'

  OAuth2::Client.new(client_id, client_secret,
    :site => 'https://podio.com',
    :authorize_path => '/oauth/authorize',
    :access_token_path => '/oauth/token')
end

def redirect_uri(path = '/auth/podio/callback', query = nil)
  uri = URI.parse(request.url)
  uri.path  = path
  uri.query = query
  uri.to_s
end

get "/" do
  %(<h1>Podio OAuth2 sample</h1> <p><a href="/auth/podio">Try to authorize</a>.</p>)
end

# access this to request a token from Podio.
get '/auth/podio' do
  url = podio_client.auth_code.authorize_url(:redirect_uri => redirect_uri)
  puts "Redirecting to URL: #{url.inspect}"
  redirect url
end

# If the user authorizes it, this request gets your access token
# and makes a successful api call.
get '/auth/podio/callback' do
  begin
    access_token = podio_client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
    "<p>Your OAuth access token: #{access_token.token}</p>"
  rescue OAuth2::HTTPError
    %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/auth/podio">Retry</a></p>)
  end
end