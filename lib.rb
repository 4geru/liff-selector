require 'dotenv/load'
require 'rest-client'
require 'json'

@token = ENV['APPLICAION']
def get_all_application
  droplet_ep = 'https://api.line.me/liff/v1/apps'
  res = JSON.parse RestClient.get droplet_ep, { :Authorization => "bearer #{@token}" }
end

def post_create_application(type, url)
  droplet_ep = 'https://api.line.me/liff/v1/apps'
  RestClient.post 'http://example.com/resource', {view: {type: type, url: url } } { |response, request, result| response.code }
end

def correct_url(url)
  begin
    uri = URI.parse(url)
    status_code = RestClient.get(url){ |response, request, result| response.code }
    return true if status_code == 200
  rescue TypeError, SocketError, URI::InvalidURIError
    puts 'erroe'
  end
  false
end