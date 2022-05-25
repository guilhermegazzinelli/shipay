module Shipay
  class ShipayObject
    attr_reader :attributes

    RESOURCES = Dir[File.expand_path('../resources/*.rb', __FILE__)].map do |path|
      File.basename(path, '.rb').to_sym
    end

    def initialize(response = {})
      # raise MissingCredentialsError.new("Missing :client_key for extra options #{options}") if options && !options[:client_key]

      @attributes = Hash.new
      @unsaved_attributes = Set.new

      @client_key = response[:client_key] ||= Shipay.default_client_key #|| :default
      update response
    end

    def []=(key,value)
      @attributes[key] = value
      @unsaved_attributes.add key
    end

    def empty?
      @attributes.empty?
    end

    def ==(other)
      self.class == other.class && id == other.id
    end

    def unsaved_attributes
      Hash[@unsaved_attributes.map do |key|
        [ key, to_hash_value(self[key], :unsaved_attributes) ]
      end]
    end

    def to_hash
      Hash[@attributes.map do |key, value|
        [ key, to_hash_value(value, :to_hash) ]
      end]
    end

    def respond_to?(name, include_all = false)
      return true if name.to_s.end_with? '='

      @attributes.has_key?(name.to_s) || super
    end

    # def to_s
    #   attributes_str = ''
    #   (attributes.keys - ['id', 'object']).sort.each do |key|
    #     attributes_str += " \033[1;33m#{key}:\033[0m#{self[key].inspect}" unless self[key].nil?
    #   end
    #   "\033[1;31m#<#{self.class.name}:\033[0;32m#{id}#{attributes_str}\033[0m\033[0m\033[1;31m>\033[0;32m"
    # end
    # # alias :inspect :to_s

    protected
    def update(attributes)
      removed_attributes = @attributes.keys - attributes.to_hash.keys

      removed_attributes.each do |key|
        @attributes.delete key
      end

      attributes.each do |key, value|
        key = key.to_s

        @attributes[key] = ShipayObject.convert(value, Util.singularize(key), @client_key)
        @unsaved_attributes.delete key
      end
    end

    def to_hash_value(value, type)
      case value
      when ShipayObject
        value.send type
      when Array
        value.map do |v|
          to_hash_value v, type
        end
      else
        value
      end
    end

    def method_missing(name, *args, &block)
      name = name.to_s

      unless block_given?
        if name.end_with?('=') && args.size == 1
          attribute_name = name[0...-1]
          return self[attribute_name] = args[0]
        end

        if args.size == 0
          return self[name] || self[name.to_sym]
        end
      end

      if attributes.respond_to? name
        return attributes.public_send name, *args, &block
      end

      super name, *args, &block
    end


    class << self
      def convert(response, resource_name = nil, client_key=nil)
        case response
        when Array
          response.map{ |i| convert i, resource_name, client_key }
        when Hash
          resource_class_for(resource_name).new(response.merge({client_key: client_key}))
        else
          response
        end
      end

      protected
      def resource_class_for(resource_name)
        return Shipay::ShipayObject if resource_name.nil?

        if RESOURCES.include? resource_name.to_sym
          Object.const_get "Shipay::#{capitalize_name resource_name}"
        else
          Shipay::ShipayObject
        end
      end

      def capitalize_name(name)
        name.gsub(/(\A\w|\_\w)/){ |str| str.gsub('_', '').upcase }
      end
    end
  end
end
