require './lib'

if __FILE__ == $0
  res = get_all_application
  puts "id liffId\t\ttype\turl"
  res['apps'].each_with_index do |v, i|
    puts "#{i+1}. #{v['liffId']}\t#{v['view']['type']}\t#{v['view']['url']}"
  end
end