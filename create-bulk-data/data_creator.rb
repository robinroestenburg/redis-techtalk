collection = [1,2,3,4,5,6,7,8,9]

File.open('bulk-large.txt', 'w') do |file|
  collection.permutation.each_with_index do |permutation, index|
    file.write("#{permutation.join}\n")
  end
end
