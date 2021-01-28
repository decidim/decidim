# frozen_string_literal: true

module Decidim
  module Core
    module NeedsApiFilterAndOrder
      # Converts the result of a GraphQL::Schema::InputObject into ActiverRecord where argument
      # Each value InputObject can return 4 types of values:
      # 1. A Scalar, will filter by a simple match (==) with the default field name
      # 2. A Hash, then the field name will be ignored and the key from the hash used for filtering
      # 3. A Proc, the input can use it to construct complex queries by using the Arel_tables syntax.
      #            The Proc will receive the model class and the locale as arguments
      # 4. An Array with entries of the 3 first types. Each entry will generate an ActiveRecord where clause
      def add_filter_keys(filter_input)
        return unless filter_input.respond_to? :each

        filter_input.each do |key, filters|
          Array.wrap(filters).each do |params|
            next if key.to_sym == :locale

            @query = if params.respond_to? :call
                       @query.where(params.call(@model_class, filter_input[:locale]))
                     elsif params.is_a? Hash
                       @query.where(params)
                     else
                       @query.where(@model_class.arel_table[key].eq(params))
                     end
          end
        end
      end

      # Converts the result of a GraphQL::Schema::InputObject into ActiverRecord order argument
      # Each value of InputObject can return 3 types of values:
      # 1. A Scalar, will order using the default field name
      # 2. A Hash, the the field name will be ignored and the key from the hash used for ordering
      # 3. A Proc, the input can use it to construct queries using Arel
      #            The Proc will receive the locale as argument
      def add_order_keys(order_input)
        order_input.map do |key, value|
          next if key.to_sym == :locale

          @query = if value.respond_to? :call
                     @query.order(value.call(order_input[:locale]))
                   elsif value.is_a? Hash
                     @query.order(value)
                   else
                     @query.order(key => value)
                   end
        end
      end
    end
  end
end
