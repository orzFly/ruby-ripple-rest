module RippleRest
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
end