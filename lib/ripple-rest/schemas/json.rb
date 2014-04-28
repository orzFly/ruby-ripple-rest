require 'autoparse'

module RippleRest
  # @!group Private APIs
  # @api private
  def self.generate_schema(fn)
    RippleRest.const_set fn, AutoParse.generate(JSON.parse(File.read(File.join(File.join(File.dirname(__FILE__), "json"), "#{fn}.json"))), :uri => "#{fn}")
  end
  # @!endgroup
  
  generate_schema :Currency
  generate_schema :FloatString
  generate_schema :Hash128
  generate_schema :Hash256
  generate_schema :ResourceId
  generate_schema :RippleAddress
  generate_schema :Timestamp
  generate_schema :UINT32
  generate_schema :URL  
  
  generate_schema :Order
  generate_schema :Balance
  generate_schema :Notification
  generate_schema :Payment
  generate_schema :Trustline
  generate_schema :AccountSettings
  generate_schema :Amount
  
  # A 
  class Notification < AutoParse::Instance
    # @!attribute account
    #   The Ripple address of the account to which the notification pertains
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute type
    #   The resource type this notification corresponds to. Possible values are "payment", "order", "trustline", "accountsettings"
    #   @return [String] +"^payment|order|trustline|accountsettings$"+


    # @!attribute direction
    #   The direction of the transaction, from the perspective of the account being queried. Possible values are "incoming", "outgoing", and "passthrough"
    #   @return [String] +"^incoming|outgoing|passthrough$"+


    # @!attribute state
    #   The state of the transaction from the perspective of the Ripple Ledger. Possible values are "validated" and "failed"
    #   @return [String] +"^validated|failed$"+


    # @!attribute result
    #   The rippled code indicating the success or failure type of the transaction. The code "tesSUCCESS" indicates that the transaction was successfully validated and written into the Ripple Ledger. All other codes will begin with the following prefixes: "tec", "tef", "tel", or "tej"
    #   @return [String] +"te[cfjlms][A-Za-z_]+"+


    # @!attribute ledger
    #   The string representation of the index number of the ledger containing the validated or failed transaction. Failed payments will only be written into the Ripple Ledger if they fail after submission to a rippled and a Ripple Network fee is claimed
    #   @return [String] +"^[0-9]+$"+


    # @!attribute hash
    #   The 256-bit hash of the transaction. This is used throughout the Ripple protocol as the unique identifier for the transaction
    #   @return [String<Hash256>] +"^$|^[A-Fa-f0-9]{64}$"+


    # @!attribute timestamp
    #   The timestamp representing when the transaction was validated and written into the Ripple ledger
    #   @return [String<Timestamp>] +"^$|^[0-9]{4}-[0-1][0-9]-[0-3][0-9]T(2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9](Z|[+](2[0-3]|[01][0-9]):[0-5][0-9])$"+


    # @!attribute transaction_url
    #   A URL that can be used to fetch the full resource this notification corresponds to
    #   @return [String]


    # @!attribute previous_notification_url
    #   A URL that can be used to fetch the notification that preceded this one chronologically
    #   @return [String]


    # @!attribute next_notification_url
    #   A URL that can be used to fetch the notification that followed this one chronologically
    #   @return [String]


  end
  # A simplified Order object used by the ripple-rest API (note that "orders" are referred to elsewhere in the Ripple protocol as "offers")
  class Order < AutoParse::Instance
    # @!attribute account
    #   The Ripple account address of the order's creator
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute buy
    #   If set to true the order it indicates that the creator is looking to receive the base_amount in exchange for the counter_amount. If undefined or set to false it indicates that the creator is looking to sell the base_amount to receive the counter_amount
    #   @return [Boolean]


    # @!attribute base_amount
    #   The amount of currency the seller_account is seeking to buy. If other orders take part of this one, this value will change to represent the amount left in the order. This may be specified along with the counter_amount OR exchange_rate but not both. When the order is parsed from the Ripple Ledger the base currency will be determined according to the Priority Ranking of Currencies (XRP,EUR,GBP,AUD,NZD,USD,CAD,CHF,JPY,CNY) and if neither currency is listed in the ranking the base currency will be the one that is alphabetically first
    #   @return [Amount]


    # @!attribute counter_amount
    #   The amount of currency being sold. If other orders take part of this one, this value will change to represent the amount left in the order. This may be specified along with the base_amount OR the exchange_rate but not both
    #   @return [Amount]


    # @!attribute exchange_rate
    #   A string representation of the order price, defined as the cost one unit of the base currency in terms of the counter currency. This may be specified along with the base_amount OR the counter_amount but not both. If it is unspecified it will be computed automatically based on the counter_amount divided by the base_amount
    #   @return [String<FloatString>]


    # @!attribute expiration_timestamp
    #   The ISO combined date and time string representing the point beyond which the order will no longer be considered active or valid
    #   @return [String<Timestamp>] +"^$|^[0-9]{4}-[0-1][0-9]-[0-3][0-9]T(2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9](Z|[+](2[0-3]|[01][0-9]):[0-5][0-9])$"+


    # @!attribute ledger_timeout
    #   A string representation of the number of ledger closes after submission during which the order should be considered active
    #   @return [String] +"^[0-9]*$"+


    # @!attribute immediate_or_cancel
    #   If set to true this order will only take orders that are available at the time of execution and will not create an entry in the Ripple Ledger
    #   @return [Boolean]


    # @!attribute fill_or_kill
    #   If set to true this order will only take orders that fill the base_amount and are available at the time of execution and will not create an entry in the Ripple Ledger
    #   @return [Boolean]


    # @!attribute maximize_buy_or_sell
    #   If set to true and it is a buy order it will buy up to the base_amount even if the counter_amount is exceeded, if it is a sell order it will sell up to the counter_amount even if the base_amount is exceeded
    #   @return [Boolean]


    # @!attribute cancel_replace
    #   If this is set to the sequence number of an outstanding order, that order will be cancelled and replaced with this one
    #   @return [String] +"^d*$"+


    # @!attribute sequence
    #   The sequence number of this order from the perspective of the seller_account. The seller_account and the sequence number uniquely identify the order in the Ripple Ledger
    #   @return [String] +"^[0-9]*$"+


    # @!attribute fee
    #   The Ripple Network transaction fee, represented in whole XRP (NOT "drops", or millionths of an XRP, which is used elsewhere in the Ripple protocol) used to create the order
    #   @return [String<FloatString>]


    # @!attribute state
    #   If the order is active the state will be "active". If this object represents a historical order the state will be "validated", "filled" if the order was removed because it was fully filled, "cancelled" if it was deleted by the owner, "expired" if it reached the expiration_timestamp, or "failed" if there was an error with the initial attempt to place the order
    #   @return [String] +"^active|validated|filled|cancelled|expired|failed$"+


    # @!attribute ledger
    #   The string representation of the index number of the ledger containing this order or, in the case of historical queries, of the transaction that modified this Order. 
    #   @return [String] +"^[0-9]+$"+


    # @!attribute hash
    #   When returned as the result of a historical query this will be the hash of Ripple transaction that created, modified, or deleted this order. The transaction hash is used throughout the Ripple Protocol to uniquely identify a particular transaction
    #   @return [String<Hash256>] +"^$|^[A-Fa-f0-9]{64}$"+


    # @!attribute previous
    #   If the order was modified or partially filled this will be a full Order object. If the previous object also had a previous object that will be removed to reduce data complexity. Order changes can be walked backwards by querying the API for previous.hash repeatedly
    #   @return [Order]


  end
  # An object 
  class AccountSettings < AutoParse::Instance
    # @!attribute account
    #   The Ripple address of the account in question
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute regular_key
    #   The hash of an optional additional public key that can be used for signing and verifying transactions
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute url
    #   The domain associated with this account. The ripple.txt file can be looked up to verify this information
    #   @return [String<URL>] +"^(ftp://|http://|https://)?([A-Za-z0-9_]+:{0,1}[A-Za-z0-9_]*@)?(^([ \\t\\r\\n\\f])+)(:[0-9]+)?(/|/([[A-Za-z0-9_]#!:.?+=&%@!-\\/]))?$"+


    # @!attribute email_hash
    #   The MD5 128-bit hash of the account owner's email address
    #   @return [String<Hash128>] +"^$|^[A-Fa-f0-9]{32}$"+


    # @!attribute message_key
    #   An optional public key, represented as hex, that can be set to allow others to send encrypted messages to the account owner
    #   @return [String] +"^([0-9a-fA-F]{2}){0,33}$"+


    # @!attribute transfer_rate
    #   A number representation of the rate charged each time a holder of currency issued by this account transfers it. By default the rate is 100. A rate of 101 is a 1% charge on top of the amount being transferred. Up to nine decimal places are supported
    #   @return [Float]


    # @!attribute require_destination_tag
    #   If set to true incoming payments will only be validated if they include a destination_tag. This may be used primarily by gateways that operate exclusively with hosted wallets
    #   @return [Boolean]


    # @!attribute require_authorization
    #   If set to true incoming trustlines will only be validated if this account first creates a trustline to the counterparty with the authorized flag set to true. This may be used by gateways to prevent accounts unknown to them from holding currencies they issue
    #   @return [Boolean]


    # @!attribute disallow_xrp
    #   If set to true incoming XRP payments will be allowed
    #   @return [Boolean]


    # @!attribute transaction_sequence
    #   A string representation of the last sequence number of a validated transaction created by this account
    #   @return [String<UINT32>] +"^$|^(429496729[0-5]|42949672[0-8][0-9]|4294967[01][0-9]{2}|429496[0-6][0-9]{3}|42949[0-5][0-9]{4}|4294[0-8][0-9]{5}|429[0-3][0-9]{6}|42[0-8][0-9]{7}|4[01][0-9]{8}|[1-3][0-9]{9}|[1-9][0-9]{8}|[1-9][0-9]{7}|[1-9][0-9]{6}|[1-9][0-9]{5}|[1-9][0-9]{4}|[1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]|[0-9])$"+


    # @!attribute trustline_count
    #   The number of trustlines owned by this account. This value does not include incoming trustlines where this account has not explicitly reciprocated trust
    #   @return [String<UINT32>] +"^$|^(429496729[0-5]|42949672[0-8][0-9]|4294967[01][0-9]{2}|429496[0-6][0-9]{3}|42949[0-5][0-9]{4}|4294[0-8][0-9]{5}|429[0-3][0-9]{6}|42[0-8][0-9]{7}|4[01][0-9]{8}|[1-3][0-9]{9}|[1-9][0-9]{8}|[1-9][0-9]{7}|[1-9][0-9]{6}|[1-9][0-9]{5}|[1-9][0-9]{4}|[1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]|[0-9])$"+


    # @!attribute ledger
    #   The string representation of the index number of the ledger containing these account settings or, in the case of historical queries, of the transaction that modified these settings
    #   @return [String] +"^[0-9]+$"+


    # @!attribute hash
    #   If this object was returned by a historical query this value will be the hash of the transaction that modified these settings. The transaction hash is used throughout the Ripple Protocol to uniquely identify a particular transaction
    #   @return [String<Hash256>] +"^$|^[A-Fa-f0-9]{64}$"+


  end
  # A flattened Payment object used by the ripple-rest API
  class Payment < AutoParse::Instance
    # @!attribute source_account
    #   The Ripple account address of the Payment sender
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute source_tag
    #   A string representing an unsigned 32-bit integer most commonly used to refer to a sender's hosted account at a Ripple gateway
    #   @return [String<UINT32>] +"^$|^(429496729[0-5]|42949672[0-8][0-9]|4294967[01][0-9]{2}|429496[0-6][0-9]{3}|42949[0-5][0-9]{4}|4294[0-8][0-9]{5}|429[0-3][0-9]{6}|42[0-8][0-9]{7}|4[01][0-9]{8}|[1-3][0-9]{9}|[1-9][0-9]{8}|[1-9][0-9]{7}|[1-9][0-9]{6}|[1-9][0-9]{5}|[1-9][0-9]{4}|[1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]|[0-9])$"+


    # @!attribute source_amount
    #   An optional amount that can be specified to constrain cross-currency payments
    #   @return [Amount]


    # @!attribute source_slippage
    #   An optional cushion for the source_amount to increase the likelihood that the payment will succeed. The source_account will never be charged more than source_amount.value + source_slippage
    #   @return [String<FloatString>]


    # @!attribute destination_account
    #   
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute destination_tag
    #   A string representing an unsigned 32-bit integer most commonly used to refer to a receiver's hosted account at a Ripple gateway
    #   @return [String<UINT32>] +"^$|^(429496729[0-5]|42949672[0-8][0-9]|4294967[01][0-9]{2}|429496[0-6][0-9]{3}|42949[0-5][0-9]{4}|4294[0-8][0-9]{5}|429[0-3][0-9]{6}|42[0-8][0-9]{7}|4[01][0-9]{8}|[1-3][0-9]{9}|[1-9][0-9]{8}|[1-9][0-9]{7}|[1-9][0-9]{6}|[1-9][0-9]{5}|[1-9][0-9]{4}|[1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]|[0-9])$"+


    # @!attribute destination_amount
    #   The amount the destination_account will receive
    #   @return [Amount]


    # @!attribute invoice_id
    #   A 256-bit hash that can be used to identify a particular payment
    #   @return [String<Hash256>] +"^$|^[A-Fa-f0-9]{64}$"+


    # @!attribute paths 
    #   A "stringified" version of the Ripple PathSet structure that users should treat as opaque
    #   @return [String]


    # @!attribute partial_payment
    #   A boolean that, if set to true, indicates that this payment should go through even if the whole amount cannot be delivered because of a lack of liquidity or funds in the source_account account
    #   @return [Boolean]


    # @!attribute no_direct_ripple
    #   A boolean that can be set to true if paths are specified and the sender would like the Ripple Network to disregard any direct paths from the source_account to the destination_account. This may be used to take advantage of an arbitrage opportunity or by gateways wishing to issue balances from a hot wallet to a user who has mistakenly set a trustline directly to the hot wallet
    #   @return [Boolean]


    # @!attribute direction
    #   The direction of the payment, from the perspective of the account being queried. Possible values are "incoming", "outgoing", and "passthrough"
    #   @return [String] +"^incoming|outgoing|passthrough$"+


    # @!attribute state
    #   The state of the payment from the perspective of the Ripple Ledger. Possible values are "validated" and "failed" and "new" if the payment has not been submitted yet
    #   @return [String] +"^validated|failed|new$"+


    # @!attribute result
    #   The rippled code indicating the success or failure type of the payment. The code "tesSUCCESS" indicates that the payment was successfully validated and written into the Ripple Ledger. All other codes will begin with the following prefixes: "tec", "tef", "tel", or "tej"
    #   @return [String] +"te[cfjlms][A-Za-z_]+"+


    # @!attribute ledger
    #   The string representation of the index number of the ledger containing the validated or failed payment. Failed payments will only be written into the Ripple Ledger if they fail after submission to a rippled and a Ripple Network fee is claimed
    #   @return [String] +"^[0-9]+$"+


    # @!attribute hash
    #   The 256-bit hash of the payment. This is used throughout the Ripple protocol as the unique identifier for the transaction
    #   @return [String<Hash256>] +"^$|^[A-Fa-f0-9]{64}$"+


    # @!attribute timestamp
    #   The timestamp representing when the payment was validated and written into the Ripple ledger
    #   @return [String<Timestamp>] +"^$|^[0-9]{4}-[0-1][0-9]-[0-3][0-9]T(2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9](Z|[+](2[0-3]|[01][0-9]):[0-5][0-9])$"+


    # @!attribute fee
    #   The Ripple Network transaction fee, represented in whole XRP (NOT "drops", or millionths of an XRP, which is used elsewhere in the Ripple protocol)
    #   @return [String<FloatString>]


    # @!attribute source_balance_changes
    #   Parsed from the validated transaction metadata, this array represents all of the changes to balances held by the source_account. Most often this will have one amount representing the Ripple Network fee and, if the source_amount was not XRP, one amount representing the actual source_amount that was sent
    #   @return [array]


    # @!attribute destination_balance_changes
    #   Parsed from the validated transaction metadata, this array represents the changes to balances held by the destination_account. For those receiving payments this is important to check because if the partial_payment flag is set this value may be less than the destination_amount
    #   @return [array]


  end
  # A simplified representation of an account Balance
  class Balance < AutoParse::Instance
    # @!attribute value
    #   The quantity of the currency, denoted as a string to retain floating point precision
    #   @return [String]


    # @!attribute currency
    #   The currency expressed as a three-character code
    #   @return [String<Currency>] +"^([a-zA-Z0-9]{3}|[A-Fa-f0-9]{40})$"+


    # @!attribute counterparty
    #   The Ripple account address of the currency's issuer or gateway, or an empty string if the currency is XRP
    #   @return [String] +"^$|^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


  end
  # An Amount on the Ripple Protocol, used also for XRP in the ripple-rest API
  class Amount < AutoParse::Instance
    # @!attribute value
    #   The quantity of the currency, denoted as a string to retain floating point precision
    #   @return [String]


    # @!attribute currency
    #   The currency expressed as a three-character code
    #   @return [String<Currency>] +"^([a-zA-Z0-9]{3}|[A-Fa-f0-9]{40})$"+


    # @!attribute issuer
    #   The Ripple account address of the currency's issuer or gateway, or an empty string if the currency is XRP
    #   @return [String] +"^$|^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute counterparty
    #   The Ripple account address of the currency's issuer or gateway, or an empty string if the currency is XRP
    #   @return [String] +"^$|^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


  end
  # A simplified Trustline object used by the ripple-rest API
  class Trustline < AutoParse::Instance
    # @!attribute account
    #   The account from whose perspective this trustline is being viewed
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute counterparty
    #   The other party in this trustline
    #   @return [String<RippleAddress>] +"^r[1-9A-HJ-NP-Za-km-z]{25,33}$"+


    # @!attribute currency
    #   The code of the currency in which this trustline denotes trust
    #   @return [String<Currency>] +"^([a-zA-Z0-9]{3}|[A-Fa-f0-9]{40})$"+


    # @!attribute limit
    #   The maximum value of the currency that the account may hold issued by the counterparty
    #   @return [String<FloatString>]


    # @!attribute reciprocated_limit
    #   The maximum value of the currency that the counterparty may hold issued by the account
    #   @return [String<FloatString>]


    # @!attribute authorized_by_account
    #   Set to true if the account has explicitly authorized the counterparty to hold currency it issues. This is only necessary if the account's settings include require_authorization_for_incoming_trustlines
    #   @return [Boolean]


    # @!attribute authorized_by_counterparty
    #   Set to true if the counterparty has explicitly authorized the account to hold currency it issues. This is only necessary if the counterparty's settings include require_authorization_for_incoming_trustlines
    #   @return [Boolean]


    # @!attribute account_allows_rippling
    #   If true it indicates that the account allows pairwise rippling out through this trustline
    #   @return [Boolean]


    # @!attribute counterparty_allows_rippling
    #   If true it indicates that the counterparty allows pairwise rippling out through this trustline
    #   @return [Boolean]


    # @!attribute ledger
    #   The string representation of the index number of the ledger containing this trustline or, in the case of historical queries, of the transaction that modified this Trustline
    #   @return [String] +"^[0-9]+$"+


    # @!attribute hash
    #   If this object was returned by a historical query this value will be the hash of the transaction that modified this Trustline. The transaction hash is used throughout the Ripple Protocol to uniquely identify a particular transaction
    #   @return [String<Hash256>] +"^$|^[A-Fa-f0-9]{64}$"+


    # @!attribute previous
    #   If the trustline was changed this will be a full Trustline object representing the previous values. If the previous object also had a previous object that will be removed to reduce data complexity. Trustline changes can be walked backwards by querying the API for previous.hash repeatedly
    #   @return [Trustline]


  end
end
