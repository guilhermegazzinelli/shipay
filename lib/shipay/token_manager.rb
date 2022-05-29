module Shipay

  class TokenManager
    attr_reader :authenticators, :mutex

    # private_class_method :new

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

    def self.token_for(key = Shipay.default_client_key)
      self.instance unless @instance
      k = Shipay::Util.to_sym(key)
      if @instance.authenticators
        @instance.mutex.synchronize do
          auth = @instance.authenticators.find { |obj| obj.key == k}
          raise MissingCredentialsError.new("Missing credentials for key: '#{key}'") if auth.blank?
          auth.token
        end
      end
    end

    def self.add_client client
      self.instance unless @instance
      client = (client.is_a? Shipay::Client)? client : Shipay::Client.new(**client)

      raise ParamError.new("Client key '#{client.key}' already exists", 'Key', '') if self.client_for client.key

      @instance.mutex.synchronize do
        @instance.authenticators << Authenticator.new(client)
      end
    end

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


    def self.client_for(key = Shipay.default_client_key)
      k = Shipay::Util.to_sym(key)

      return nil unless @instance.authenticators.present?

      @instance.mutex.synchronize do
        auth = @instance.authenticators.find { |obj| obj.key == k}
        auth&.client
      end
    end

    def self.client_type_for key = Shipay.default_client_key
      client_for(key)&.type || :pdv
    end

    def self.instance
      return @instance if @instance

      @instance = TokenManager.new
    end
  end
end

