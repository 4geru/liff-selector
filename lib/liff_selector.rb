require "liff_selector/version"
require 'json'
require 'rest-client'

module LiffSelector
  def self.run(argv)
    case argv[0]
    when 'show'
      show
    when 'same'
      same
    when 'create'
      raise ArgumentError, 'give _type_ _url_' if argv.length != 3
      create(type: argv[1], url: argv[2])
    when 'clean'
      clean
    when 'delete'
      raise ArgumentError, 'give _liff_id_' if argv.length != 2
      delete(liff_id: argv[1])
    else 
      raise NotImplementedError, 'unknow command given'
    end
  end

  private
  # command
  def self.show
    puts "id liffId\t\ttype\turl"
    self.get_all_application.each_with_index do |application, i|
      puts "#{i+1}. #{application['liffId']}\t#{application['view']['type']}\t#{application['view']['url']}"
    end
  end

  def self.same
    apps = get_all_application
    uniq_app = apps.map{|app| {type: app['view']['type'], url: app['view']['url'] } }.uniq
    delete_apps = uniq_app.map{|uapp|
      same_apps = apps
      .map.with_index{|app, i| app.store('id', i + 1); app }
      .select{|app| uapp[:type] == app['view']['type'] and uapp[:url] == app['view']['url']}

      puts "> \"type\" : #{uapp[:type]}\t \"url\" : #{uapp[:url]}"
      puts " - same application No.#{same_apps.map{|app| app['id'] }.join(' No.')} =="
      same_apps[1..-1]
    }.flatten!
  end

  def self.create(type:, url:)
    raise ArgumentError, 'not correct uri' unless correct_url(url)
    raise ArgumentError, 'not correct type please choose [compact, tall, full]' unless ["compact", "tall", "full"].include?(type)
    puts '>> making liff application >>'
    response = post_create_application(type, url)
    case response[:status]
    when 200
      puts '> [SUCESS] make application'
      puts "> application uri : line://app/#{response[:liffId]}"
    else
      puts '> [FAILED] make application'
    end
  end

  def self.clean
    apps = get_all_application
    uniq_app = apps.map{|app| {type: app['view']['type'], url: app['view']['url'] } }.uniq
    delete_apps = uniq_app.map{|uapp|
      same_apps = apps
      .map.with_index{|app, i| app.store('id', i + 1); app }
      .select{|app| uapp[:type] == app['view']['type'] and uapp[:url] == app['view']['url']}

      puts ">== same application No.#{same_apps.map{|app| app['id'] }.join(' No.')} =="
      puts "> \"type\" : #{uapp[:type]}\t \"url\" : #{uapp[:url]}"
      same_apps[1..-1]
    }.flatten!

    unless delete_apps.empty?
      begin
        delete_apps.map{|app|
          raise unless delete_delete_application(app['liffId'])
          puts ">> delete \"id\" : #{app[:id]}\t\"type\" : #{app[:type]}\t\"url\" : #{app[:url]}"
        }
        puts '> [SUCESS] delete application'
      rescue
        puts '> [FAILED] cannot delete application'
      end
    else
      puts ">> There is not same application"
    end
  end

  def self.delete(liff_id:)
    application = get_all_application[liff_id.to_i-1]
    puts "#{liff_id}. #{application['liffId']}\t#{application['view']['type']}\t#{application['view']['url']}"
    if delete_delete_application(application['liffId'])
      puts '> [SUCESS] delete application'
    else
      puts '> [FAILED] cannot delete application'
    end
  end

  # http request
  def self.get_all_application
    token = ENV['LINE_TOKEN']
    droplet_ep = 'https://api.line.me/liff/v1/apps'
    res = JSON.parse(RestClient.get droplet_ep, { :Authorization => "bearer #{token}" })['apps']
  end

  def self.delete_delete_application(liff_id)
    token = ENV['LINE_TOKEN']
    droplet_ep = "https://api.line.me/liff/v1/apps/#{liff_id}"
    RestClient.delete droplet_ep, { :Authorization => "bearer #{token}" } { |response, request, result| response.code == 200 }
  end

  def self.correct_url(url)
    begin
      uri = URI.parse(url)
      status_code = RestClient.get(url){ |response, request, result| response.code }
      return true if status_code == 200
    rescue TypeError, SocketError, URI::InvalidURIError
      puts 'erroe'
    end
    false
  end

  def self.post_create_application(type, url)
    token = ENV['LINE_TOKEN']
    droplet_ep = 'https://api.line.me/liff/v1/apps'
    RestClient.post(droplet_ep, {view: {type: type, url: url } }.to_json, {:Authorization => "bearer #{token}", :content_type => :json}) { |response, request, result| {status: response.code, liffId: JSON.parse(response)["liffId"]} }
  end
end
