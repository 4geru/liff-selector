require './lib'
require './show'

def uri
  puts '> select uri application id'
  id = gets.gsub("\n", '').to_i
  application = get_all_application[id-1]
  puts "> [SELECTED] #{id}. #{application['liffId']}\t#{application['view']['type']}\t#{application['view']['url']}"
  puts "> this application uri : line://app/#{application['liffId']}"
end

if __FILE__ == $0
  show
  uri
end