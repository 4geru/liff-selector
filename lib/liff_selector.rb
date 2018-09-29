require "liff_selector/version"
require 'json'
require 'rest-client'
require 'dotenv/load'

module LiffSelector
  @token = ENV['LINE_CHANNEL_TOKEN']
  @request_url = 'https://api.line.me/liff/v1/apps'
  def self.run(argv)
    case argv[0]
    when 'show'
      show
    when 'same'
      same
    when 'upload'
      raise ArgumentError, 'give _type_ _url_' if argv.length != 3
      upload(type: argv[1], url: argv[2])
    when 'clean'
      clean
    when 'delete'
      raise ArgumentError, 'give _liff_id_' if argv.length != 2
      delete(liff_id: argv[1])
    when 'help'
      help
    when 'create'
      raise ArgumentError, 'give _file_name_' if argv.length != 2
      create(file_name: argv[1])
    else 
      raise NotImplementedError, 'unknow command given'
    end
  end

  private
  # command
  def self.show
    puts "id liffId\t\ttype\turl"
    all_apps.each_with_index do |app, i|
      puts "#{i+1}. #{app["liffId"]}\t#{app["view"]["type"]}\t#{app["view"]["url"]}"
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

  def self.create(file_name:)
    FileUtils.mkdir_p('./views') unless FileTest.exist?('./views')
    sample = File.read(File.join( File.dirname(__FILE__), '/assets/sample.html'))
    File.write("./views/#{file_name}.erb", sample)
    puts "> [SUCESS] make ./views/#{file_name}.erb"
  end

  def self.upload(type:, url:)
    raise ArgumentError, 'not correct type please choose [compact, tall, full]' unless ["compact", "tall", "full"].include?(type)
    puts '> make liff app'

    # api request
    response = RestClient.post(@request_url, {view: {type: type, url: url } }.to_json, {:Authorization => "bearer #{@token}", :content_type => :json})
    result = JSON.parse(response)

    puts '> [SUCCESS] make app'
    puts "> app uri : line://app/#{result['liffId']}"
  end

  def self.clean
    delete_apps = same

    raise ArgumentError, 'not same app' if delete_apps.empty?

    begin
      delete_apps.map{|app|
        # api request
        RestClient.delete "#{@request_url}/#{app["liffId"]}", { :Authorization => "bearer #{@token}" }
        puts ">> delete \"id\": #{app["id"]}, \"type\": #{app["view"]["type"]}, \"url\": #{app["view"]["url"]}"
      }
      puts '> [SUCESS] delete apps'
    rescue
      puts '> [FAILED] cannot delete app'
    end
  end

  def self.help
    help =
<<'EOS'
liff_select show                  : display all apps
liff_select same                  : display same url and type apps
liff_select clean                 : delete same url and type apps
liff_select upload _TYPE_ _URL_   : upload new apps with type and url.
                                  : type is <type:compact|tall:|full>
liff_select delete _LIFF_ID_      : delete app _LIFF_ID_ is referenced show number.
liff_select help                  : commands helps
liff_select new _html_name_       : make liff sample html
EOS
    puts help
  end

  def self.delete(liff_id:)
    # [TODO] undefined liff_id
    app = all_apps[liff_id.to_i-1]
    puts "#{liff_id}. #{app['liffId']}\t#{app['view']['type']}\t#{app['view']['url']}"

    # api request
    RestClient.delete "#{@request_url}/#{app['liffId']}", { :Authorization => "bearer #{@token}" }
    puts '> [SUCESS] delete app'
  end

  # http request
  def self.all_apps
    JSON.parse(RestClient.get @request_url, { :Authorization => "bearer #{@token}" })['apps']
  rescue => e
    []
  end
end
