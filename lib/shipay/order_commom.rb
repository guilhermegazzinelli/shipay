module Shipay
  class OrderCommom < Model

    # def self.url(*params)
    #   byebug
    #   ["/#{ CGI.escape underscored_class_name }", *params].join '/'
    # end

    def refund(params={})
      raise ParamError.new("Missing ammount param", :amount, :float, url('refund')) unless params.has_key? :amount
      update Shipay::Request.delete(url('refund'), params: params.merge(client_key: @client_key)).call(class_name)
    end

    def primary_key
      order_id
    end

    def cancel()
      update Shipay::Request.delete(url, client_key: @client_key).call(class_name)
    end
  end
end
