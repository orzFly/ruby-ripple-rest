require 'json'
schemas = {}
Dir["*.json"].each do |i|
  key = File.basename(i, ".json")
  schemas[key] = JSON.parse File.read i
end

puts <<'EOF'
require 'autoparse'

module RippleRest
  # @!group Private APIs
  # @api private
  def self.generate_schema(fn)
    RippleRest.const_set fn, AutoParse.generate(JSON.parse(File.read(File.join(File.join(File.dirname(__FILE__), "json"), "#{fn}.json"))), :uri => "#{fn}")
  end
  # @!endgroup
  
  generate_schema :Currency
  generate_schema :FloatString
  generate_schema :Hash128
  generate_schema :Hash256
  generate_schema :ResourceId
  generate_schema :RippleAddress
  generate_schema :Timestamp
  generate_schema :UINT32
  generate_schema :URL  
  
  generate_schema :Order
  generate_schema :Balance
  generate_schema :Notification
  generate_schema :Payment
  generate_schema :Trustline
  generate_schema :AccountSettings
  generate_schema :Amount
  
EOF
schemas.values.select{|i|i["type"] == "object"}.each do |json|
  key = json["title"]
  puts "  # #{json["description"]}"
  puts "  class #{key} < AutoParse::Instance"
  
  json["properties"].each do |k, v|
    type = ""
    if v["type"] == "string" && v["pattern"]
      type = "[String] +#{v["pattern"].inspect}+"
    elsif v["type"] == "string"
      type = "[String]"
    elsif v["type"] == "boolean"
      type = "[Boolean]"
    elsif v["type"] == "float"
      type = "[Float]"
    elsif v["$ref"] == "FloatString"
      type = "[BigDecimal]"
    elsif v["$ref"] == "UInt32"
      type = "[UInt32]"
    elsif v["$ref"] && schemas[v["$ref"]]["type"] == "string"
      type = "[String<#{v["$ref"]}>] +#{schemas[v["$ref"]]["pattern"].inspect}+"
    elsif v["$ref"]
      type = "[#{v["$ref"]}]"
    elsif
      type = "[#{v["type"]}]"
    end
    
    puts "    # @!attribute #{k}"
    puts "    #   #{v["description"]}"
    puts "    #   @return #{type}"
    puts
    puts
  end
  puts "  end"
end
puts "end"