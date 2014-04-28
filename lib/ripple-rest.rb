module RippleRest; end
  
require 'json'
require 'cgi'
require 'bigdecimal'
require 'autoparse'
require 'rest-client'
require 'ripple-rest/version'
require 'ripple-rest/errors'
require 'ripple-rest/schemas/json'
require 'ripple-rest/schemas/account'
require 'ripple-rest/schemas/account_settings'
require 'ripple-rest/schemas/trustlines'
require 'ripple-rest/schemas/balance'
require 'ripple-rest/schemas/notifications'
require 'ripple-rest/schemas/order'
require 'ripple-rest/schemas/amount'
require 'ripple-rest/schemas/payments'

class << RippleRest
  def setup endpoint
    @endpoint = endpoint.gsub %r|/$|, ""
  end
  
  def get uri, args = {}
    wrap_error { RestClient.get "#{@endpoint}/#{uri}", args }
  end
  
  def post uri, args = {}
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
      raise RippleRest::RippleRestError.new(json["message"], json) unless json["success"]
    end
  
    if !response || response.code != 200
      raise RippleRest::ProtocolError.new "Protocol is wrong or network is down", response
    end
    
    json || response.to_str
  end
  
  def get_transaction hash
    get("v1/transactions/#{hash}")["transaction"]
  end
  
  def server_connected?
    get("v1/server/connected")["connected"]
  end
  
  def server_info
    get("v1/server")
  end
  
  def next_uuid
    get("v1/uuid")["uuid"]
  end
end
  