module RippleRest
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
        uri += "?#{cur}"
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
end