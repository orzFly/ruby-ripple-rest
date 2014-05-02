#!/usr/bin/env ruby -Ilib
require 'ripple-rest'

RippleRest.setup "http://localhost:5990"

p RippleRest.server_connected?
p RippleRest.server_info
p RippleRest.next_uuid
p RippleRest.get_transaction "A29DED58C4EA3D04FD4501108AB9AE6EBEF3249E892E34A2351C4A1A1A88E90B"

account = RippleRest::Account.new "rES1hSkoWauMk3r6sgh7zfjpTCnwGbqaxA", "sSECRET"
p account.balances
p account.settings
p account.trustlines
# account.trustlines.add ({
#   "limit" => 5,
#   "currency" => "ICE",
#   "counterparty" => "r4H3F9dDaYPFwbrUsusvNAHLz2sEZk4wE5"
# })

# p account.notifications["DD9F40516152090612B12F1CCD5A88828AEA8813FEBD56D9D6B39ED918F4CCCA"];
# Known issue: invalid date: "+046323-04-12T13:26:40.000Z" (ArgumentError)

p account.payments.find_path "rhtgn6PYbXwhA6QJJMY4btieoap31t7Uo8", "5+ICE+rES1hSkoWauMk3r6sgh7zfjpTCnwGbqaxA"
p account.payments.query :results_per_page => 10

payment = account.payments.create "rES1hSkoWauMk3r6sgh7zfjpTCnwGbqaxA", "5+XRP"
payment.submit