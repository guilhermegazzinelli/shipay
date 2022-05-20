module Shipay
  class WalletList < Model
    def self.url(*params)
      ["/v1/#{ CGI.escape underscored_class_name }s", *params].join '/'
    end

    def self.all()
      Shipay::Request.get(url).call(class_name)
    end
  end
end
