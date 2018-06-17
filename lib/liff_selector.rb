require "liff_selector/version"
require 'json'
require 'rest-client'

module LiffSelector
  @token = ENV['LINE_TOKEN']
  @request_url = 'https://api.line.me/liff/v1/apps'
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
    self.all_apps.each_with_index do |app, i|
      puts "#{i+1}. #{app['liffId']}\t#{app['view']['type']}\t#{app['view']['url']}"
    end
  end

  def self.same
    apps = all_apps
    uniq_app = apps.map{|app| {type: app['view']['type'], url: app['view']['url'] } }.uniq
    delete_apps = uniq_app.map{|delete_app|
      same_apps = apps
      .map.with_index{|app, i| app.store('id', i + 1); app }
      .select{|app| delete_app[:type] == app['view']['type'] and delete_app[:url] == app['view']['url']}

      puts "> \"type\": #{delete_app[:type]}, \"url\": #{delete_app[:url]}"
      same_apps.map{|app| puts " - id: #{app['id']}, liffId: #{app['liffId']}" }
      same_apps[1..-1]
    }.flatten!
  end

  def self.create(type:, url:)
    raise ArgumentError, 'not correct uri' unless correct_url(url)
    raise ArgumentError, 'not correct type please choose [compact, tall, full]' unless ["compact", "tall", "full"].include?(type)
    puts '> make liff app'
    response = JSON.parse(create_app(type, url))

    puts '> [SUCESS] make app'
    puts "> app uri : line://app/#{response['liffId']}"
  end

  def self.clean
    delete_apps = same

    raise ArgumentError, 'not same app' if delete_apps.empty?

    begin
      delete_apps.map{|app|
        delete_app(app["liffId"])
        puts ">> delete \"id\": #{app["id"]}, \"type\": #{app["view"]["type"]}, \"url\": #{app["view"]["url"]}"
      }
      puts '> [SUCESS] delete app'
    rescue
      puts '> [FAILED] cannot delete app'
    end
  end

  def self.delete(liff_id:)
    app = all_apps[liff_id.to_i-1]
    puts "#{liff_id}. #{app['liffId']}\t#{app['view']['type']}\t#{app['view']['url']}"
    if delete_app(app['liffId'])
      puts '> [SUCESS] delete app'
    else
      puts '> [FAILED] cannot delete app'
    end
  end

  # http request
  def self.all_apps
    res = JSON.parse(RestClient.get @request_url, { :Authorization => "bearer #{@token}" })['apps']
  end

  def self.delete_app(liff_id)
    RestClient.delete "#{@request_url}/#{liff_id}", { :Authorization => "bearer #{@token}" }
  end

  def self.correct_url(url)
    uri = URI.parse(url)
    status_code = RestClient.get(url)
  end

  def self.create_app(type, url)
    RestClient.post(@request_url, {view: {type: type, url: url } }.to_json, {:Authorization => "bearer #{@token}", :content_type => :json})
  end
end
