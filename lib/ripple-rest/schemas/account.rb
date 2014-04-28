module RippleRest
  class Account
    # Account's Address (rXXXXXX...)
    # @return [String]
    attr_accessor :address
    
    # Account's secret
    # @return [String]
    attr_accessor :secret
    
    def initialize address, secret = nil
      @address = address
      @secret = secret
    end
    
    # Get an account's existing balances.
    # This includes XRP balance (which does not include a counterparty) and trustline balances.
    # @return [Array<Balance>]
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    def balances
      RippleRest
        .get("v1/accounts/#{@address}/balances")["balances"]
        .map(&Balance.method(:new))
    end
    
    # Returns a Trustlines object for this account.
    # @return [Trustlines]
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    def trustlines
      data = RippleRest
        .get("v1/accounts/#{@address}/trustlines")["trustlines"]
        .map(&Trustline.method(:new))
      obj = Trustlines.new data
      obj.account = self
      obj
    end
    
    # Returns a AccountSettings object for this account.
    # @return [AccountSettings]
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    def settings
      data = RippleRest.get("v1/accounts/#{@address}/settings")["settings"]
      obj = AccountSettings.new data
      obj.account = self
      obj
    end
    
    # Returns a Notifications object for this account.
    # @return [Notifications]
    def notifications
      @notifications ||= lambda {
        obj = Notifications.new
        obj.account = self
        obj
      }.call
    end
    
    # Returns a Payments object for this account.
    # @return [Payments]
    def payments
      payments ||= lambda {
        obj = Payments.new
        obj.account = self
        obj
      }.call
    end
    
    # Returns the address of attribute address.
    # @return [String]
    def to_s
      address
    end
    
    # @!group Private APIs
    # @api private
    def require_secret
      raise ArgumentError.new("Secret is required for this operation.") unless secret
    end
    # @!endgroup
  end
end