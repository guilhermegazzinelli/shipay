module Shipay
  class OrderCommom < Model

    # def self.url(*params)
    #   byebug
    #   ["/#{ CGI.escape underscored_class_name }", *params].join '/'
    # end

    #
    # Request refund to Shipay api for this order
    #
    # @param [Hash] params Parameters for function
    # @option params [Numeric] :amount (Required) The amount that will be refunded in float format
    # @return [Order] Return model order instance
    # @example Refund 1.0 from order
    #     order_instance.refund(amount: 1.0)
    def refund(params={})
      raise ParamError.new("Missing ammount param", :amount, :float, url('refund')) unless params.has_key? :amount
      update Shipay::Request.delete(url('refund'), params: params.merge(client_key: @client_key)).call(class_name)
      self
    end

    #
    # Defines primary key for model
    #
    # @return [String] Return the primary_key field value
    def primary_key
      order_id
    end

    #
    # Request order Cancel to Shipay api
    #
    # @return [Order] Return model order instance
    def cancel()
      update Shipay::Request.delete(url, client_key: @client_key).call(class_name)
      self
    end
  end
end
