require 'rubygems'
#require 'hiredis'
#require 'redis/connection/hiredis'
require 'redis'
require 'time'

$redis = Redis.new(:host => '127.0.0.1',
                   :port => 6379)
$redis.flushall

count = 0
start = Time.now

File.open(ARGV[0]).each do |line|
  count += 1
  $redis.sadd("keys:all", line.strip)

  puts "#{count}" if (count % 10_000 == 0)
end

puts "#{count} items in #{Time.now - start} seconds"
