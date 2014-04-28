module RippleRest
  generate_schema :Notification
  
  class Notifications
    attr_accessor :account
    
    def [] hash
      Notification.new RippleRest
        .get("v1/accounts/#{account.address}/notifications/#{hash}")["notification"]
    end
  end
end