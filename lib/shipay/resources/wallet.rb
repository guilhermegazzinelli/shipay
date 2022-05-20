# {
#   "active": true,
#   "friendly_name": "Shipay Pagador",
#   "logo": null,
#   "minimum_payment": 0.0,
#   "pix_dict_key": null,
#   "pix_psp": null,
#   "wallet": "shipay-pagador",
#   "wallet_setting_id": null,
#   "wallet_setting_name": null
# }
# path = '/v1/wallets'
module Shipay
  class Wallet < Model
    def self.url(*params)
      ["/v1/#{ CGI.escape underscored_class_name }s", *params].join '/'
    end

    def self.all()
      Shipay::Request.get(url).call(class_name)
    end
  end
end
