require './lib'

def show
  puts "id liffId\t\ttype\turl"
  get_all_application.each_with_index do |application, i|
    puts "#{i+1}. #{application['liffId']}\t#{application['view']['type']}\t#{application['view']['url']}"
  end
end

if __FILE__ == $0
  show
end