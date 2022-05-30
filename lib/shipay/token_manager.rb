module Shipay

  #
  # Class to manage Tokens with singleton structure
  #
  class TokenManager
    attr_reader :authenticators, :mutex

    # private_class_method :new

    #
    # Initializes TokenManager
    #
    # This class builds authentication array with a mutex to share tokens
    def initialize()
      tokens = nil
      if Shipay.credentials
        case Shipay.credentials
        when Array
          tokens = Shipay.credentials
        when Hash
          tokens = [ShiShipay.credentials]
        end
      else
        tokens = [{
          secret_key: Shipay.secret_key,
          access_key: Shipay.access_key,
          client_id: Shipay.client_id,
          key: :default,
          default: true
        }]
      end

      @mutex = Mutex.new
      @authenticators = nil
      setup_autenticators tokens
    end

    #
    # Sets authenticators based on tokens passed by constructor
    #
    # @param [Array] tokens Array of tokens to be registered as clients
    #
    # @return [Array] Authenticators array
    #
    def setup_autenticators tokens
      return @authenticators if @authenticators
      tokens = tokens.map{|t| Shipay::Client.new(**t)}
      @mutex.synchronize do
        @authenticators = []
        tokens.each do |client|
          @authenticators << Authenticator.new(client)
        end
      end
    end

    #
    # Find a token for a specific Client Key
    #
    # @param [Symbol] key Client Key to be found in Authenticators Array
    #
    # @return [String] Auth token
    #
    def self.token_for(key = :default)
      self.instance unless @instance
      k = Shipay::Util.to_sym(key)
      raise MissingCredentialsError.new("Missing credentials for key: '#{key}'") unless @instance.authenticators

      @instance.mutex.synchronize do
        auth = @instance.authenticators.find { |obj| obj.key == k}

        raise MissingCredentialsError.new("Missing credentials for key: '#{key}'") if auth.blank?
        auth.token
      end
    end

    #
    # Registers a new client to be used
    #
    # @param [Shipay::Client] client Client instance to be registered in TokenManager
    #
    # @return [Array] Authenticators array
    # @example Ads a new client to be used in calls to Shipay Api
    #     Shipay::TokenManager.add_client Client.new(client_id: <CLIENT_KEY>, key: :<CLIENT_ALIAS>)
    def self.add_client client
      self.instance unless @instance
      client = (client.is_a? Shipay::Client)? client : Shipay::Client.new(**client)

      raise ParamError.new("Client key '#{client.key}' already exists", 'Key', '') if self.client_for client.key

      @instance.mutex.synchronize do
        @instance.authenticators << Authenticator.new(client)
      end
    end



    #
    # Find a Client for a specific Key
    #
    # @param [Symbol] key Client Key to be found in Authenticators Array ( Defaults to Shipay.default_client_key)
    #
    # @return [Shipay::Client] Client instance registed with the key passed
    #
    def self.client_for(key = Shipay.default_client_key)
      k = Shipay::Util.to_sym(key)

      return nil unless @instance.authenticators.present?

      @instance.mutex.synchronize do
        auth = @instance.authenticators.find { |obj| obj.key == k}
        auth&.client
      end
    end

    #
    # Find a Client Type for a specific Key
    #
    # @param [Symbol] key Client Key to be found in Authenticators Array ( Defaults to Shipay.default_client_key)
    #
    # @return [Symbol] Return the cleint type ( :pdv or :e_commerce) ( Defaults to :pdv if not found)
    #
    def self.client_type_for key = Shipay.default_client_key
      client_for(key)&.type || :pdv
    end

    def self.instance
      return @instance if @instance

      @instance = TokenManager.new
    end
  end
end

