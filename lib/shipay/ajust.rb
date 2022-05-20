tokens = [{key: 'a'}, {key: 'b'}, {key: 'c'}]

  class Configuration


  end

  class ClientSetting
    attr_accessor :access_token, :secret, :client_id

    attr_reader :a_token

    def initialize(access_token, secret, client_id)
      @access_token = access_token
      @secret = secret
      @client_id = client_id
    end


  end

  class TokenManager

    attr_reader :authenticators, :mutex

    def initialize(tokens)
      @mutex = Mutex.new
      @authenticators = nil
      setup_autenticators tokens
    end

    def setup_autenticators tokens
      return @authenticators if @authenticators

      @mutex.synchronize do
        @authenticators = []
        tokens.each do |hash|
          @authenticators << Authenticator.new(hash)
        end
      end
    end

    def self.token_for key
      if @instance.authenticators
        @instance.mutex.synchronize do
          @instance.authenticators.find { |obj| obj.key == key }.return_some_processing
        end
      end
    end

    def self.instance tokens
      return @instance if @instance

      @instance = TokenManager.new(tokens)
    end
  end

  class ThreadContext
    def self.get_global_context

    end
  end

  class Authenticator
    attr_reader :key

    def initialize options = {}
      @key = options[:key]
      @value = options[:value]
      @token = nil

      get_token
    end

    def get_token
      @token = rand
    end

    def return_some_processing
      @token * 2
    end
  end

  TokenManager.instance tokens
  TokenManager.token_for 'b'

