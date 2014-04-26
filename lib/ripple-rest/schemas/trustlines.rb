module RippleRest
  class Trustlines
    include Enumerable
    
    attr_accessor :account
    
    def initialize data
      @data = data
    end
    
    def each *args, &block
      @data.each *args, &block
    end
    
    def add obj
      raise ArgumentError.new("Account is missing.") unless account
      account.require_secret
      
      hash = {}
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