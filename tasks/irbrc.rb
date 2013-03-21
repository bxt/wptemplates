
require 'wirble'
%w{init colorize}.each { |str| Wirble.send(str) }

require 'irb/completion'

require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 500
IRB.conf[:HISTORY_FILE] = ".irb_history"

IRB.conf[:AUTO_INDENT] = true

require 'pp'
require 'wptemplates'

puts "Welcome to Wptemplates #{Wptemplates::VERSION}!"
