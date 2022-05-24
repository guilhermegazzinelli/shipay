require_relative 'lib/shipay'

Shipay.secret_key = 'Q__g6ie850Pv4jVBQUeyAMA_mlJH3xG1Acg2FiPU_lYpVol9z69RHmOE4BZDMaHVGsMEg1s9BI5pvgKkCAWDdw'
Shipay.access_key='CyUqG2hSfQJbE8OTWfy1fQ'
Shipay.client_id='ubceuMCPeVygHW8xynrFYzbF3JKE1zlnpjNBReM6gDz0jzQ-5clVgRdtRRDJ5yWENkGMnC3VI2wQSyu_507g5c9ujS6D5eOSBVheKbMVbEW8qk8dYb41yqgl7o9xv-puarpHV7Dk3jv6n6_HZlAl4S8gHjNsayuj2RSqT8AbtY4'


# Shipay::Authenticator.instance()

# Shipay::Authenticator.headers
sh = Shipay::Order.new({
	order_ref: "shipaypag-001",
	wallet: "shipay-pagador",
	total: 0.51,
	items: [
		{
			item_title: "Item 1",
			unit_price: 0.30,
			quantity: 1
		},
		{
			item_title: "Item 2",
			unit_price: 0.20,
			quantity: 1
		},
		{
			item_title: "Item 3",
			unit_price: 0.01,
			quantity: 1
		}
	],
	buyer: {
		name: "Shipay PDV",
		cpf_cnpj: "121.191.870-02",
		email: "shipay-pagador@shipay.com.br",
		phone: "+55 11 99999-9999"
	}
}).create

  puts sh
  # Shipay.api_endpoint='https://postman-echo.com/get'

  ord = Shipay::Order.find_by_id(sh.order_id)

  puts ord
