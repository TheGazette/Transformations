input = File.open(ARGV[0])
output = File.open(ARGV[1],"w")

while buff = input.read(4096)
  output.write(buff.sub('"[]>','" "../schema/LondonGazette.dtd" []>'))
end

input.close()
output.close()