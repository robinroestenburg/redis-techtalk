def generate_redis_protocol(*cmd)
  protocol = ""
  protocol << "*"+cmd.length.to_s+"\r\n"
  cmd.each{|arg|
    protocol << "$"+arg.to_s.bytesize.to_s+"\r\n"
    protocol << arg.to_s+"\r\n"
  }
  protocol
end

collection = [0,1,2,3,4,5,6,7,8,9]

File.open('bulk-large.txt', 'w') do |file|
  collection.permutation.each_with_index do |permutation, index|
    file.write(generate_redis_protocol("SADD", "keys:all", permutation.join))
  end
end
