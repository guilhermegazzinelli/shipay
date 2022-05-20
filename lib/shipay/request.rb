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
        # raise Shipay::RequestError, 'You need to configure keys before performing requests.' unless Shipay.api_key && Shipay.access_key && Shipay.client_id

        @path       = path
        @method     = method
        @parameters = options[:params]  || nil
        @query      = options[:query]   || Hash.new
        @headers    = options[:headers] || Hash.new
    end

    def run
      response = RestClient::Request.execute request_params
      MultiJson.decode response.body

      rescue RestClient::Exception => error
        begin
          parsed_error = MultiJson.decode error.http_body

          if error.is_a? RestClient::ResourceNotFound
            if parsed_error['errors']
              raise Shipay::NotFound.new(parsed_error, request_params, error)
            else
              raise Shipay::NotFound.new(nil, request_params, error)
            end
          else
            if parsed_error['errors']
              raise Shipay::ValidationError.new parsed_error
            else
              raise Shipay::ResponseError.new(request_params, error)
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
      ShipayObject.convert run, ressource_name
    end

    def self.get(url, options={})
      self.new url, 'GET', options
    end

    def self.post(url, options={})
      #byebug
      self.new url, 'POST', options
    end

    def self.put(url, options={})
      self.new url, 'PUT', options
    end

    def self.patch(url, options={})
      #byebug
      self.new url, 'PATCH', options
    end

    def self.delete(url, options={})
      self.new url, 'DELETE', options
    end

    def request_params
      #byebug
      aux = {
        method:       method,
        url:          full_api_url,

        # headers:      DEFAULT_HEADERS.merge(Shipay::Authenticator.token )
        headers:      DEFAULT_HEADERS.merge(Shipay::Authenticator.token )

        # ssl_version:  'TLSv1_2'
      }
      aux.merge!({ payload:      MultiJson.encode(parameters)}) if parameters
      puts aux
      aux
    end

    def full_api_url
      Shipay.api_endpoint + path
    end
  end

end
