# frozen_string_literal: true

require_relative "shipay/version"

module Shipay
  class Error < StandardError; end
  # Your code goes here...

  class << self
    attr_accessor :api_endpoint, :api_key, :api_secret, :client_id, :callback_url
  end

  # @api_endpoint = (production?)? "https://" : "https://api-staging.shipay.com.br"
  @api_endpoint =  "https://api-staging.shipay.com.br"

  def self.production?
    ENV["RACK_ENV"] == "production" ||
      ENV["RAILS_ENV"] == "production" ||
      ENV["PRODUCTION"] ||
      ENV["production"] || (Rails.env.production? if Object.const_defined?(Rails))
  end
end
