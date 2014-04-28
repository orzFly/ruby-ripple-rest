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
      
      hash = to_hash
      hash["secret"] = account.secret
      
      RippleRest.post "v1/accounts/#{account.address}/settings", hash
    end
  end
end