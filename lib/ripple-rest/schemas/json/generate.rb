require 'json'
schemas = {}
Dir["*.json"].each do |i|
  key = File.basename(i, ".json")
  schemas[key] = JSON.parse File.read i
end

schemas.values.select{|i|i["type"] == "object"}.each do |json|
  key = json["title"]
  puts "# #{json["description"]}"
  puts "class #{key} < RestObject"
#json["properties"].each do |i|
  # @!attribute [r] count
#   @return [Fixnum] the size of the list
#end
  puts "end"
end