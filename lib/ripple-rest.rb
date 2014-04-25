module RippleRest; end
  
require 'json'
require 'bigdecimal'
require 'autoparse'
require 'rest-client'
require 'ripple-rest/version'
require 'ripple-rest/errors'
require 'ripple-rest/schemas/json'
require 'ripple-rest/schemas/account'
require 'ripple-rest/schemas/account_settings'
require 'ripple-rest/schemas/balance'

class << RippleRest
  def setup endpoint
    @endpoint = endpoint.gsub %r|/$|, ""
  end
  
  def get uri, args = {}
    wrap_error { RestClient.get "#{@endpoint}/#{uri}", args }
  end
  
  def post uri, args = {}
    p args.to_json
    wrap_error { RestClient.post "#{@endpoint}/#{uri}", args, :content_type => :json }
  end
  
  def wrap_error
    unless @endpoint
      raise ArgumentError.new "You have to setup RippleRest first."
    end
    
    begin
      response = yield
    rescue => e
      response = e.response if e.respond_to? :response
    end
    
    json = JSON.parse response.to_str rescue nil
    if json
      raise RippleRest::RippleRestError.new json["message"] unless json["success"]
    end
  
    if response.code != 200
      raise RippleRest::ProtocolError.new "Protocol is wrong or network is down", response
    end
    
    json
  end
end
  