require 'dotenv/load'
require 'rest-client'
require 'json'

@token = ENV['APPLICAION']
def get_all_application
  droplet_ep = 'https://api.line.me/liff/v1/apps'
  res = JSON.parse RestClient.get droplet_ep, { :Authorization => "bearer #{@token}" }
end