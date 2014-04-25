module RippleRest
  SCHEMA_ROOT = File.join(File.dirname(__FILE__), "json")
  
  def self.generate_schema(fn)
    RippleRest.const_set fn, AutoParse.generate(JSON.parse(File.read(File.join(SCHEMA_ROOT, "#{fn}.json"))), :uri => "#{fn}")
  end
  
  generate_schema :Currency
  generate_schema :FloatString
  generate_schema :Hash128
  generate_schema :Hash256
  generate_schema :ResourceId
  generate_schema :RippleAddress
  generate_schema :Timestamp
  generate_schema :UINT32
  generate_schema :URL
  
  generate_schema :Amount
  generate_schema :Notification
  generate_schema :Order
  generate_schema :Payment
  generate_schema :Trustline
end