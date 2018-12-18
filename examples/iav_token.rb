require 'dwolla_v2'

$dwolla = DwollaV2::Client.new(
  id: ENV["DWOLLA_ID"],
  secret: ENV["DWOLLA_SECRET"]
) { |c| c.environment ENV["DWOLLA_ENV"] }

t = $dwolla.auths.client

puts t.post("customers/#{ENV["DWOLLA_CUSTOMER_ID"]}/iav-token").inspect
