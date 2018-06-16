require './lib'
require 'uri'

def create()
  puts '> please input url'
  url = gets.gsub("\n", '')
  unless correct_url(url)
    puts 'it is not correct uri'
    return
  end
  puts '> correct uri'

  while true do
    puts 'please input type[compact/tall/full]'
    type = gets.gsub("\n", '')
    break if ["compact", "tall", "full"].include?(type)
  end
  puts '> correct type!'
  puts '>> making liff application >>'
  status = post_create_application(type, url)
  puts status
  case status
  when 200
    puts '> [SUCESS] make application'
  else
    puts '> [FAILED] make application'
  end
end

if __FILE__ == $0
  create()
end