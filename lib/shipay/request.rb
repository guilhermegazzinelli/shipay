require 'uri'
require 'rest_client'
require 'multi_json'
require 'byebug'


DEFAULT_HEADERS = {
  'Content-Type' => 'application/json; charset=utf8',
  'Accept'       => 'application/json',
  'User-Agent'   => "shipay-ruby/#{Shipay::VERSION}"
}

module Shipay
  class Request
    attr_accessor :path, :method, :parameters, :headers, :query

    def initialize(path, method, options={})
        @path       = path
        @method     = method
        @parameters = options[:params]      || nil
        @query      = options[:query]       || Hash.new
        @headers    = options[:headers]     || Hash.new
        @auth       = options[:auth]        || false
        @client_key = options[:client_key]  || @parameters && ( @parameters[:client_key] || @parameters["client_key"] ) || Shipay.default_client_key
    end

    def run
      response = RestClient::Request.execute request_params
      MultiJson.decode response.body

      rescue RestClient::Exception => error
        begin
          parsed_error = MultiJson.decode error.http_body

          if error.is_a? RestClient::ResourceNotFound
            if parsed_error['message']
              raise Shipay::NotFound.new(parsed_error, request_params, error)
            else
              raise Shipay::NotFound.new(nil, request_params, error)
            end
          else
            if parsed_error['message']
              raise Shipay::ResponseError.new(request_params, error, parsed_error['message'])
            else
              raise Shipay::ValidationError.new parsed_error
            end
          end
        rescue MultiJson::ParseError
          raise Shipay::ResponseError.new(request_params, error)
        end
      rescue MultiJson::ParseError
        raise Shipay::ResponseError.new(request_params, response)
      rescue SocketError
        raise Shipay::ConnectionError.new $!
      rescue RestClient::ServerBrokeConnection
        raise Shipay::ConnectionError.new $!
    end

    def call(ressource_name)
      ShipayObject.convert run, ressource_name, @client_key
    end

    def self.get(url, options={})
      pp options
      self.new url, 'GET', options
    end

    def self.auth(url, options={})
      options[:auth] = true
      self.new url, 'POST', options
    end

    def self.post(url, options={})
      self.new url, 'POST', options
    end

    def self.put(url, options={})
      self.new url, 'PUT', options
    end

    def self.patch(url, options={})
      self.new url, 'PATCH', options
    end

    def self.delete(url, options={})
      self.new url, 'DELETE', options
    end

    def request_params
      aux = {
        method:       method,
        url:          full_api_url,
      }

      parameters&.reject! do |k, v|
        if v.is_a?(Hash)
          v.reject!{ |k, v|  k == :client_key}
        else
          k == :client_key
        end
      end

      if !@auth && parameters && Shipay.callback_url && Shipay::TokenManager.client_type_for(@client_key) == :e_comerce && method == 'POST'
        aux.merge!({ payload:      MultiJson.encode(parameters.merge({callback_url: Shipay.callback_url}))})
      elsif parameters
        aux.merge!({ payload:      MultiJson.encode(parameters)})
      end
      extra_headers = DEFAULT_HEADERS
      extra_headers[:authorization] = "Bearer #{Shipay::TokenManager.token_for @client_key}" unless @auth
      extra_headers["x-shipay-order-type"] = "e-order" if (!@auth && Shipay::TokenManager.client_type_for(@client_key) == :e_comerce)

      aux.merge!({ headers: extra_headers })
      pp aux
      aux
    end

    def full_api_url
      Shipay.api_endpoint + path
    end
  end

end
