require './lib'
require './show'

def delete
  puts '> select delete application id'
  id = gets.gsub("\n", '').to_i
  application = get_all_application[id-1]
  puts "#{id}. #{application['liffId']}\t#{application['view']['type']}\t#{application['view']['url']}"
  puts '> delete this application[Y/N]'
  return if gets.gsub("\n", '').upcase != 'Y'
  if delete_delete_application(application['liffId'])
    puts '> [SUCESS] delete application'
  else
    puts '> [FAILED] cannot delete application'
  end
end

if __FILE__ == $0
  show
  delete
end