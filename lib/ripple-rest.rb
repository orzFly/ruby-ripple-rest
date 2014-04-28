module RippleRest; end
  
require 'json'
require 'cgi'
require 'bigdecimal'
require 'rest-client'
require 'ripple-rest/version'
require 'ripple-rest/errors'
require 'ripple-rest/rest-object'
require 'ripple-rest/generated-schemas'
require 'ripple-rest/schemas'
require 'ripple-rest/helpers'

class << RippleRest
  # Set endpoint URI
  # @param endpoint [String] "http://localhost:5990/"
  def setup endpoint
    @endpoint = endpoint.gsub %r|/$|, ""
  end
  
  # Retrieve the details of a transaction in the standard Ripple JSON format. 
  # @return [Hash] See the Ripple Wiki page on [Transaction Formats](https://ripple.com/wiki/Transactions) for more information.
  # @raise [RippleRestError] if RippleRest server returns an error
  # @raise [ProtocolError] if protocol is wrong or network is down
  def get_transaction hash
    get("v1/transactions/#{hash}")["transaction"]
  end
  
  # A simple endpoint that can be used to check if ripple-rest is connected to a rippled and is ready to serve. If used before querying the other endpoints this can be used to centralize the logic to handle if rippled is disconnected from the Ripple Network and unable to process transactions.
  # @return [Boolean] true if `ripple-rest` is ready to serve
  # @raise [RippleRestError] if RippleRest server returns an error
  # @raise [ProtocolError] if protocol is wrong or network is down
  def server_connected?
    get("v1/server/connected")["connected"]
  end
  
  # Retrieve information about the ripple-rest and connected rippled's current status.
  # @return [Hash] https://github.com/ripple/ripple-rest/blob/develop/docs/api-reference.md#get-server-info
  # @raise [RippleRestError] if RippleRest server returns an error
  # @raise [ProtocolError] if protocol is wrong or network is down
  def server_info
    get("v1/server")
  end
  
  # A UUID v4 generator.
  # @return [String] "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  # @raise [RippleRestError] if RippleRest server returns an error
  # @raise [ProtocolError] if protocol is wrong or network is down
  def next_uuid
    get("v1/uuid")["uuid"]
  end
  
  # @!group Private APIs
  
  # @api private
  def get uri, args = {}
    wrap_error { RestClient.get "#{@endpoint}/#{uri}", args }
  end
  
  # @api private
  def post uri, args = {}
    wrap_error { RestClient.post "#{@endpoint}/#{uri}", args, :content_type => :json }
  end
  
  # @api private
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
  
  #@!endgroup
end
  