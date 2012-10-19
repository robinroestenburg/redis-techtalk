require 'rubygems'
require 'redis'
require 'time'

$redis = Redis.new(:host => '127.0.0.1',
                   :port => 6379)
$redis.flushall


def batch(lines)
  $redis.pipelined do

    lines.each do |line|
      $redis.sadd('keys:all', line.strip)
    end
  end
end

count = 0
start = Time.now
lines = []

File.open(ARGV[0]).each do |line|
  count += 1

  lines << line

  if (count % 1_000 == 0)
    batch(lines)
    lines = []
  end

  puts "#{count}" if (count % 10_000 == 0)
end


puts "#{count} items in #{Time.now - start} seconds"
