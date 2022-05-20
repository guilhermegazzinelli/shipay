
module Shipay
  class Model < ShipayObject

    def create
      update Shipay::Request.post(self.class.url, params: to_hash).call(class_name)
      self
    end

    def save
      update Shipay::Request.put(url, params: unsaved_attributes).call(class_name)
      self
    end

    def url(*params)
      raise RequestError.new('Invalid ID') unless id.present?
      self.class.url CGI.escape(id.to_s), *params
    end

    def class_name
      self.class.to_s.split('::').last
    end


    class << self

      def create(*args, &block)
        self.new(*args, &block).create
      end

      def find_by_id(id)
        raise RequestError.new('Invalid ID') unless id.present?
        Shipay::Request.get(url id).call class_name
      end
      alias :find :find_by_id

      # def find_by(params = Hash.new, page = nil, count = nil)
      #   params = extract_page_count_or_params(page, count, **params)
      #   raise RequestError.new('Invalid page count') if params[:page] < 1 or params[:count] < 1

      #   Shipay::Request.get(url, params: params).call
      # end
      # alias :find_by_hash :find_by

      # def all(*args, **params)
      #   params = extract_page_count_or_params(*args, **params)
      #   find_by params
      # end
      # alias :where :all

      def url(*params)
        ["/#{ CGI.escape underscored_class_name }", *params].join '/'
      end

      def class_name
        self.name.split('::').last.downcase
      end

      def underscored_class_name
        class_name.gsub(/[a-z0-9][A-Z]/){|s| "#{s[0]}_#{s[1]}"}.downcase
      end

      def extract_page_count_or_params(*args, **params)
        params[:page]  ||= args[0] || 1
        params[:count] ||= args[1] || 10
        params
      end

    end
  end
end
