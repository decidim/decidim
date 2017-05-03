module Decidim
  module Exporters
    class CSV
      def initialize(serializer)
        @serializer = serializer
      end

      def export(collection)
        collection.map do |resource|
          @serializer.new(resource).serialize.inject({}) do |result, (key, value)|
            result.merge!(flatten(key, value))
          end
        end
      end

      def flatten(key, object)
        if object.kind_of? Hash
          object.inject({}) do |result, (subkey, value)|
            result.merge(flatten("#{key}__#{subkey}", value))
          end
        elsif object.kind_of?(Array)
          {
            key => object.map(&:to_s).join(", ")
          }
        else
          {
            key => object
          }
        end
      end
    end
  end
end
