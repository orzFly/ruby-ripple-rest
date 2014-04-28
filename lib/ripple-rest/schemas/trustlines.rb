module RippleRest
  class Trustlines
    include Enumerable
    
    # @return [Account]
    attr_accessor :account
    
    def initialize data
      @data = data
    end
    
    # Use with Enumerable
    def each *args, &block
      @data.each *args, &block
    end
    
    # Add trustline
    # @param obj [String, Hash] Either a string representation of trustline limit, Hash containing value, currency, counterparty or a string form value/currency/counterparty.
    # @param allow_rippling [Boolean] See [here](https://ripple.com/wiki/No_Ripple) for details
    # @raise [ArgumentError] if secret is missing from the Account object
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    def add obj, allow_rippling = true
      raise ArgumentError.new("Account is missing.") unless account
      account.require_secret
      
      hash = {}
      hash["allow_rippling"] = allow_rippling
      hash["secret"] = account.secret
      
      if obj.is_a? String
        hash["trustline"] = { "limit" => obj }
      else
        hash["trustline"] = obj.to_hash
      end
      
      RippleRest.post "v1/accounts/#{account.address}/trustlines", hash
    end
  end
end