require 'dotenv/load'
require 'rest-client'
require 'json'

@token = ENV['APPLICAION']
def get_all_application
  droplet_ep = 'https://api.line.me/liff/v1/apps'
  res = JSON.parse(RestClient.get droplet_ep, { :Authorization => "bearer #{@token}" })['apps']
end

def post_create_application(type, url)
  droplet_ep = 'https://api.line.me/liff/v1/apps'
  RestClient::Request.execute(method: :post, url: droplet_ep,
                            payload: "{view: {type: #{type}, url: #{url} } }", headers: {:Authorization => "bearer #{@token}"})
  # RestClient.post(droplet_ep, {view: {type: type, url: url } }, {:Authorization => "bearer #{@token}", :content_type => :json})
end

def delete_delete_application(liff_id)
  droplet_ep = "https://api.line.me/liff/v1/apps/#{liff_id}"
  RestClient.delete droplet_ep, { :Authorization => "bearer #{@token}" } { |response, request, result| response.code == 200 }
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
# post_create_application('full', 'https://liff-a4geru.c9users.io/')