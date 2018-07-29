#ref https://robots.thoughtbot.com/redis-pub-sub-how-does-it-work

require 'redis'
require 'json'

def pub_as channel, user
  redis = Redis.new port: 6389
  data = {user: user}
  loop do
    puts '>'
    msg = STDIN.gets
    redis.publish channel, data.merge(msg: msg.strip).to_json
  end
end

def sub_to *channel
  redis = Redis.new port: 6389, timeout: 0
  redis.subscribe(*channel) do |on|
    on.message do |chan, payload|
      data = JSON.parse(payload)
      puts "msg: #{channel} - #{data}"
    end
  end
end 

__END__

有用的命令： 
redis-3.0.3-cli -p 6389 monitor

do like below:

in client1 console:
load 'trial/pubsub.rb'
pub_as 'ruby', 'cao'

in client2 console:
load 'trial/pubsub.rb'
sub_to 'ruby'

# todo performance test
