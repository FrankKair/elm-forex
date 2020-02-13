require 'sinatra'
require 'json'
require 'fafx'

before do
  response['Access-Control-Allow-Origin'] = '*'
  Fafx::ExchangeRate.update_data
end

get '/' do
  Fafx::ExchangeRate.get('GBP', 'USD').to_s
end

get '/*/to/*' do
  currencies = params['splat']
  to = currencies[0]
  from = currencies[1]
  result = Fafx::ExchangeRate.get(to, from).to_s
  JSON.generate(:result => result)
end

get '/currencies' do
  JSON.generate(:currencies => Fafx::ExchangeRate.currencies_available)
end
