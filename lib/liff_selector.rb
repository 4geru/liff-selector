require "liff_selector/version"
require 'json'
require 'rest-client'

module LiffSelector
  def self.run(argv)
    case argv[0]
    when 'show'
    puts "token #{ENV['LINE_TOKEN']}"
      puts "id liffId\t\ttype\turl"
      get_all_application.each_with_index do |application, i|
        puts "#{i+1}. #{application['liffId']}\t#{application['view']['type']}\t#{application['view']['url']}"
      end
    else 
      raise NotImplementedError, 'unknow command given'
    end
  end

  def self.get_all_application
    token = ENV['LINE_TOKEN']
    droplet_ep = 'https://api.line.me/liff/v1/apps'
    res = JSON.parse(RestClient.get droplet_ep, { :Authorization => "bearer #{token}" })['apps']
  end
end
