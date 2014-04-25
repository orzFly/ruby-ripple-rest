module RippleRest
  generate_schema :AccountSettings
  
  class AccountSettings
    attr_accessor :account
    
    def save
      raise ArgumentError.new("Account is missing.") unless account
      
      account.require_secret
      
      hash = to_hash
      hash["secret"] = account.secret
      
      RippleRest.post "v1/accounts/#{account.address}/settings", hash
    end
  end
end