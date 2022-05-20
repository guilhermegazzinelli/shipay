# {
# 	"order_ref": "shipaypag-001",
# 	"wallet": "shipay-pagador",
# 	"total": 0.51,
# 	"items": [
# 		{
# 			"item_title": "Item 1",
# 			"unit_price": 0.30,
# 			"quantity": 1
# 		},
# 		{
# 			"item_title": "Item 2",
# 			"unit_price": 0.20,
# 			"quantity": 1
# 		},
# 		{
# 			"item_title": "Item 3",
# 			"unit_price": 0.01,
# 			"quantity": 1
# 		}
# 	],
# 	"buyer": {
# 		"name": "Shipay PDV",
# 		"cpf_cnpj": "121.191.870-02",
# 		"email": "shipay-pagador@shipay.com.br",
# 		"phone": "+55 11 99999-9999"
# 	}
# }
# path = '/order'
module Shipay
  class Order < Model

    def self.url(*params)
      ["/#{ CGI.escape underscored_class_name }", *params].join '/'
    end

    def refund(params={})
      update PagarMe::Request.post(url('refund'), params: params).call(class_name)
    end

    def cancel(params={})
      update PagarMe::Request.post(url('refund'), params: params).call(class_name)
    end
  end
end
