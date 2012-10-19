require 'rubygems'
require 'redis/distributed'
require 'redis'
require 'time'

$redis = Redis::Distributed.new(["redis://localhost:6379/",
                                 "redis://localhost:6380/"])
$redis.flushall

count = 0
start = Time.now

File.open(ARGV[0]).each do |line|
  count += 1
  key, value = line.split(',')
  $redis.set(key, value.strip)

  puts "#{count}" if (count % 10_000 == 0)
end

puts "#{count} items in #{Time.now - start} seconds"
