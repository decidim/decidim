# frozen_string_literal: true

module Decidim
  module Core
    module NeedsFilterAndOrder
      # Converts the result of a GraphQL::Schema::InputObject into ActiverRecord where argument
      # Each value InputObject can return 4 types of values:
      # 1. A Scalar, will filter by a simple match (==) with the default field name
      # 2. A Hash, then the field name will be ignored and the key from the hash used for filtering
      # 3. A Proc, the input can use it to construct complex queries by using the Arel_tables syntax.
      #            The Proc will receive the model class as argument
      # 4. An Array with entries of the 3 first types. Each entry will generate an ActiveRecord where clause
      def add_filter_keys(filter_input)
        return unless filter_input.respond_to? :each

        filter_input.each do |key, filters|
          Array.wrap(filters).each do |params|
            @query = if params.respond_to? :call
                       @query.where(params.call(@model_class))
                     elsif params.is_a? Hash
                       @query.where(params)
                     else
                       @query.where(@model_class.arel_table[key].eq(params))
                     end
          end
        end
      end

      # Converts the result of a GraphQL::Schema::InputObject into ActiverRecord order argument
      # Each value of InputObject can return 2 types of values:
      # 1. A Scalar, will order using the default field name
      # 2. A Hash, the the field name will be ignored and the key from the hash used for ordering
      def add_order_keys(order_input)
        order = order_input.map do |key, value|
          value.is_a?(Hash) ? value : { key => value }
        end
        @query = @query.order(order) if order
      end
    end
  end
end
