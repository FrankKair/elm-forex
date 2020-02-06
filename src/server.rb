require 'sinatra'
require 'json'
require 'fafx'

before do
  response['Access-Control-Allow-Origin'] = '*'
  Fafx::ExchangeRate.update_data
end

get '/' do
  Fafx::ExchangeRate.at(Date.today, 'GBP', 'USD').to_s
end

get '/*/to/*' do
  currencies = params['splat']
  to = currencies[0]
  from = currencies[1]
  Fafx::ExchangeRate.at(Date.today, to, from).to_s
end

get '/currencies' do
  JSON.generate(:currencies => Fafx::ExchangeRate.currencies_available)
end