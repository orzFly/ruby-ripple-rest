module RippleRest
  generate_schema :Payment

  class Payment
    def account
      @account
    end
    
    def account= val
      @account = val
      self.source_account = val.address
    end
    
    def submit
      @account.require_secret
      
      hash = {}
      hash["payment"] = self.to_hash
      hash["secret"] = @account.secret
      hash["client_resource_id"] = RippleRest.next_uuid
      
      RippleRest.post("v1/payments", hash)["client_resource_id"]
    end
  end
  
  class Payments
    attr_accessor :account
    
    def [] hash
      Payment.new RippleRest
        .get("v1/accounts/#{account.address}/payments/#{hash}")["payment"]
    end
    
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
    
    def create destination_account, destination_amount
      payment = Payment.new
      payment.account = account
      payment.destination_account = destination_account.to_s
      payment.destination_amount = Amount.from_string(destination_amount)
      payment
    end
  end
end