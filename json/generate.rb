require 'json'
schemas = {}
Dir["*.json"].each do |i|
  key = File.basename(i, ".json")
  schemas[key] = JSON.parse File.read i
end

puts <<'EOF'
module RippleRest
EOF

schemas.values.select{|i|i["type"] == "string"}.each do |json|
  key = json["title"].to_sym
  puts "  RestTypeHelper.register_string #{key.inspect}, #{json["pattern"].inspect}"
end
puts

schemas.values.select{|i|i["type"] == "object"}.each do |json|
  key = json["title"]
  puts "  class #{key} < RestObject; end"
  puts "  RestTypeHelper.register_object #{key.to_sym.inspect}, #{key}"
end
puts

schemas.values.select{|i|i["type"] == "object"}.each do |json|
  key = json["title"]
  puts "  # #{json["description"]}"
  puts "  class #{key}"
  
  json["properties"].each do |k, v|
    type = ""
    typeobj = nil
    if v["type"] == "string" && v["pattern"]
      type = "[String] +#{v["pattern"].inspect}+"
      typeobj = [:String, v["pattern"]]
    elsif v["type"] == "string"
      type = "[String]"
      typeobj = :String
    elsif v["type"] == "boolean"
      type = "[Boolean]"
      typeobj = :Boolean
    elsif v["type"] == "array"
      type = "[Array<#{v["items"]["$ref"]}>]"
      typeobj = [:Array, v["items"]["$ref"].to_sym]
    elsif v["type"] == "float"
      type = "[Float]"
      typeobj = :Float
    elsif v["$ref"] == "FloatString"
      type = "[BigDecimal]"
      typeobj = :FloatString
    elsif v["$ref"] == "UInt32"
      type = "[UInt32]"
      typeobj = :UINT32
    elsif v["$ref"] == "Timestamp"
      type = "[Time]"
      typeobj = :Timestamp
    elsif v["$ref"] == "URL"
      type = "[URI]"
      typeobj = :URL
    elsif v["$ref"] && (!schemas[v["$ref"]] || schemas[v["$ref"]]["type"] == "string")
      type = "[String<#{v["$ref"]}>]"
      typeobj = v["$ref"].to_sym
    elsif v["$ref"]
      type = "[#{v["$ref"]}]"
      typeobj = v["$ref"].to_sym
    elsif
      raise "Unsupported type"
    end
    
    puts "    # @!attribute #{k}"
    puts "    #   #{v["description"]}"
    puts "    #   @return #{type}"
    puts "    property #{k.to_sym.inspect}, #{typeobj.inspect}"
    puts "    required #{k.to_sym.inspect}" if (json["required"] || []).include?(k)
    puts
  end
  puts "  end"
end
puts "end"