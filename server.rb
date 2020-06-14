require 'sinatra'

get '/' do
	"Hello worldfdsfds"
end

get '/hello' do
	"Hello #{params['name']}"
end

