# frozen_string_literal: true

require_relative "shipay/version"
require_relative "shipay/authenticator"
require_relative "shipay/request"
require_relative "shipay/object"
require_relative "shipay/model"
require_relative "shipay/core_ext"
require_relative "shipay/errors"
require_relative "shipay/util"
require_relative "shipay/token_manager"
require_relative "shipay/order_commom"


Dir[File.expand_path('../shipay/resources/*.rb', __FILE__)].map do |path|
  require path
end

module Shipay
  class Error < StandardError; end

  class << self
    attr_accessor :access_key, :secret_key, :client_id, :callback_url, :credentials, :default_client_key
    attr_reader :api_endpoint
  end

  @default_client_key = :default

  # @api_endpoint = (production?)? "https://" : "https://api-staging.shipay.com.br"
  @api_endpoint =  "https://api-staging.shipay.com.br"
  # @api_endpoint = 'https://postman-echo.com/get'

  def self.production?
    ENV["RACK_ENV"] == "production" ||
      ENV["RAILS_ENV"] == "production" ||
      ENV["PRODUCTION"] ||
      ENV["production"] || (Rails.env.production? if Object.const_defined?(Rails))
  end
end
