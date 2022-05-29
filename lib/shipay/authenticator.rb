require 'jwt'

module Shipay
  CLIENT_TYPES = %i(pdv e_comerce)

  class Client
    attr_reader :secret_key, :access_key, :client_id, :key, :type
    attr_accessor :default

    def initialize(**options)
      begin
        @secret_key = options.fetch(:secret_key, Shipay.secret_key)
        @access_key = options.fetch(:access_key, Shipay.access_key)
        @client_id = options.fetch(:client_id)
        @key = Shipay::Util.to_sym(options.fetch(:key, Shipay.default_client_key ))
        @default = options.fetch(:default, true)
        @type = options.fetch(:type, :pdv)
        raise ParamError.new("Incorrect client type, must be one of #{CLIENT_TYPES}", :type, "Symbol") unless CLIENT_TYPES.include? @type
      rescue KeyError => e
        raise ParamError.new("Missing data for credentials: #{e.key}, (#{e.message})", "Credentials", "Symbol or String") unless CLIENT_TYPES.include? @type
      end
    end

    def to_h
      {
        secret_key: @secret_key,
        access_key: @access_key,
        client_id: @client_id,
        key: @key
      }
    end
  end

    class Authenticator
      attr_reader :key, :client

      def initialize(client)
        @client = client
        @key = client.key
        authenticate
      end

      def token
        refresh_token_if_expired
        @a_token
      end

      private

      def authenticate
        set_token_from_request Shipay::Request.auth('/pdvauth', {params: {client_id: @client.client_id, secret_key: @client.secret_key, access_key: @client.access_key, client_key: @key}}).run
      end

      def refresh_token
        set_token_from_request Shipay::Request.auth('/refresh-token', {headers:   {  authorization: 'Bearer ' + @r_token}, client_key: @key}).run
      end

      def refresh_token_if_expired
        refresh_token if Time.at(JWT.decode(@a_token, nil, false).first.dig('exp')) < Time.now()
      end

      def set_token_from_request response
        @a_token = response['access_token']
        @r_token = response['refresh_token']
      end
  end
end
