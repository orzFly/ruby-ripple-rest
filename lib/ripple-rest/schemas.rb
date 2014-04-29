module RippleRest
  class AccountSettings
    # @return [Account]
    attr_accessor :account
    
    # Save the account settings
    # @raise [ArgumentError] if secret is missing from the Account object
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    # @return [void]
    def save
      raise ArgumentError.new("Account is missing.") unless account
      
      account.require_secret
      
      hash = {}
      hash["settings"] = to_hash
      hash["secret"] = account.secret
      
      RippleRest.post "v1/accounts/#{account.address}/settings", hash
    end
  end
  
  class Amount
    # @return [String]
    def to_s
      "#{value}+#{currency}#{issuer.to_s.size > 0 ? ("+" + issuer) : ""}"
    end
    
    # @param s [String, Amount] an Amount object or a String like "1+XRP" or "1+USD+r..."
    # @return [Amount]
    def self.from_string s
      return s if s.is_a?(Amount)
      
      arr = s.split("+")
      Amount.new({
        "value" => arr[0],
        "currency" => arr[1],
        "issuer" => arr[2]
      })
    end
  end
  
  class Balance
    # @return [String]
    def inspect
      "#{value.to_s} #{currency}#{counterparty.to_s.size > 0 ? " (#{counterparty})" : ""}"
    end
  end
  
  class Payment
    # Gets Account object of this Payment's source account
    def account
      @account
    end
    
    # Sets source account and secret for this Payment
    # @param val [Account]
    def account= val
      @account = val
      self.source_account = val.address
    end
    
    # Submits a payment
    # @return [String] Client resource ID
    # @raise [ArgumentError] if secret is missing from the Account object
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    def submit
      @account.require_secret
      
      hash = {}
      hash["payment"] = self.to_hash
      hash["secret"] = @account.secret
      hash["client_resource_id"] = client_resource_id = RippleRest.next_uuid
      
      RippleRest.post("v1/payments", hash)["client_resource_id"]
    end
    
    # @return [String]
    attr_accessor :client_resource_id
  end
end