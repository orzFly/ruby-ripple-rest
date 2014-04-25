module RippleRest
  class Account
    attr_accessor :address
    attr_accessor :secret
    
    def initialize address, secret = nil
      @address = address
      @secret = secret
    end
    
    def balances
      RippleRest
        .get("v1/accounts/#{@address}/balances")["balances"]
        .map(&Balance.method(:new))
    end
    
    def settings
      data = RippleRest.get("v1/accounts/#{@address}/settings")["settings"]
      obj = AccountSettings.new data
      obj.account = self
      obj
    end
    
    def require_secret
      raise ArgumentError.new("Secret is required for this operation.") unless secret
    end
  end
end