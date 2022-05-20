module Shipay

  class TokenManager
    attr_reader :authenticators, :mutex

    def initialize()
      @tokens = nil
      if Shipay.credentials
        case Shipay.credentials
        when Array
          @tokens = Shipay.credentials
        when Hash
          @tokens = [ShiShipay.credentials]
        end
      else
        @tokens = [{
          secret_key: Shipay.secret_key,
          access_key: Shipay.access_key,
          client_id: Shipay.client_id,
          key: :default,
          default: true
        }]
      end

      @mutex = Mutex.new
      @authenticators = nil
      setup_autenticators
    end

    def setup_autenticators
      return @authenticators if @authenticators
      @tokens = @tokens.map{|t| Shipay::Client.new(t)}
      @mutex.synchronize do
        @authenticators = []
        @tokens.each do |client|
          @authenticators << Authenticator.new(client)
        end
      end
    end

    def self.token_for key = :default
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
    def self.token_for key = :default
      self.instance unless @instance
      k = Shipay::Util.to_sym(key)
      if @instance.authenticators
        @instance.mutex.synchronize do
          auth = @instance.authenticators.find { |obj| obj.key == k}
          raise MissingCredentialsError.new("Missing credentials for key: '#{key}'") if auth.blank?
          auth.client
        end
      end
    end

    def self.instance
      return @instance if @instance

      @instance = TokenManager.new()
    end
  end
end

# class ThreadContext
#   def self.get_global_context

#   end
# end
