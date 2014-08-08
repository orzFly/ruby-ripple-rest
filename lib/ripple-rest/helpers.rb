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
  
  class Notifications
    # @return [Account]
    attr_accessor :account
    
    # Get notifications.
    # 
    # Clients using notifications to monitor their account activity should pay particular attention to the `state` and `result` fields. The `state` field will either be `validated` or `failed` and represents the finalized status of that transaction. The `result` field will be `tesSUCCESS` if the `state` was validated. If the transaction failed, `result` will contain the `rippled` or `ripple-lib` error code.
    # 
    # Notifications have `next_notification_url` and `previous_notification_url`'s. Account notifications can be polled by continuously following the `next_notification_url`, and handling the resultant notifications, until the `next_notification_url` is an empty string. This means that there are no new notifications but, as soon as there are, querying the same URL that produced this notification in the first place will return the same notification but with the `next_notification_url` set.
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    # @return [Notification]
    def [] hash
      Notification.new RippleRest
        .get("v1/accounts/#{account.address}/notifications/#{hash}")["notification"]
    end
  end
  
  class Payments
    # @return [Account]
    attr_accessor :account
    
    # Returns an individual payment.
    # @param hash [String] Payment hash or client resource ID
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    # @return [Payment]
    def [] hash
      Payment.new RippleRest
        .get("v1/accounts/#{account.address}/payments/#{hash}")["payment"]
    end
    
    # Query `rippled` for possible payment "paths" through the Ripple Network to deliver the given amount to the specified `destination_account`. If the `destination_amount` issuer is not specified, paths will be returned for all of the issuers from whom the `destination_account` accepts the given currency.
    # @param destination_account [String, Account] destination account
    # @param destination_amount [String, Amount] destination amount
    # @param source_currencies [Array<String>] an array of source currencies that can be used to constrain the results returned (e.g. `["XRP", "USD+r...", "BTC+r..."]`) Currencies can be denoted by their currency code (e.g. USD) or by their currency code and issuer (e.g. `USD+r...`). If no issuer is specified for a currency other than XRP, the results will be limited to the specified currencies but any issuer for that currency will do.
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    # @return [Array<Payment>]
    def find_path destination_account, destination_amount, source_currencies = nil
      uri = "v1/accounts/#{account.address}/payments/paths/#{destination_account.to_s}/#{destination_amount.to_s}"
      
      if source_currencies
        cur = source_currencies.join(",")
        uri += "?source_currencies=#{cur}"
      end
      
      RippleRest.get(uri)["payments"].map(&Payment.method(:new)).map do |i|
        i.account = account
      end
    end
    
    # Create a Payment object with some field filled.
    # @return [Payment]
    def create destination_account, destination_amount
      payment = Payment.new
      payment.account = account
      payment.destination_account = destination_account.to_s
      payment.destination_amount = Amount.from_string(destination_amount)
      payment
    end
    
    # Browse historical payments in bulk.
    # @option options [String, Account] :source_account If specified, limit the results to payments initiated by a particular account
    # @option options [String, Account] :destination_account If specified, limit the results to payments made to a particular account
    # @option options [Boolean] :exclude_failed if set to true, this will return only payment that were successfully validated and written into the Ripple Ledger
    # @option options [String] :start_ledger If earliest_first is set to true this will be the index number of the earliest ledger queried, or the most recent one if earliest_first is set to false. Defaults to the first ledger the rippled has in its complete ledger. An error will be returned if this value is outside the rippled's complete ledger set
    # @option options [String] :end_ledger If earliest_first is set to true this will be the index number of the most recent ledger queried, or the earliest one if earliest_first is set to false. Defaults to the last ledger the rippled has in its complete ledger. An error will be returned if this value is outside the rippled's complete ledger set
    # @option options [Boolean] :earliest_first Determines the order in which the results should be displayed. Defaults to true
    # @option options [Fixnum] :results_per_page Limits the number of resources displayed per page. Defaults to 20
    # @option options [Fixnum] :page The page to be displayed. If there are fewer than the results_per_page number displayed, this indicates that this is the last page
    # @raise [RippleRestError] if RippleRest server returns an error
    # @raise [ProtocolError] if protocol is wrong or network is down
    # @return [Array<Payment>]
    def query options = {}
      qs = ""
      if options && options.size > 0
        qs = "?" + options.map { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
      end
      
      uri = "v1/accounts/#{account.address}/payments#{qs}"
      
      RippleRest.get(uri)["payments"].map do |i|
        payment = Payment.new(i["payment"])
        payment.client_resource_id = i["client_resource_id"]
        payment
      end
    end
  end
  
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
