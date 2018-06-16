require './lib'
require './show'

def delete
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
    puts ">> delete apps No.#{delete_apps.map{|app| app['id']}.join(' No.')}"
    puts '> delete this application[Y/N]'
    return if gets.gsub("\n", '').upcase != 'Y'
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

if __FILE__ == $0
  show
  delete
end