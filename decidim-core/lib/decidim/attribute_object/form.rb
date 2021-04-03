# frozen_string_literal: true

module Decidim
  module AttributeObject
    class Form
      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attr_reader :context

      def self.mimic(model_name)
        @model_name = model_name.to_s.underscore.to_sym
      end

      def self.mimicked_model_name
        @model_name || infer_model_name
      end

      # Converts the mimiced name to ActiveModel naming.
      def self.model_name
        return super if name

        ActiveModel::Name.new(self, nil, mimicked_model_name.to_s)
      end

      def self.from_model(model)
        form = new(model.attributes.select { |name, _val| model.respond_to?(name) })
        form.map_model(model)

        form
      end

      def self.from_params(params, additional_params = {})
        params_hash = hash_from(params)
        mimicked_params = ensure_hash(params_hash[mimicked_model_name])

        attributes_hash = params_hash.merge(mimicked_params).merge(additional_params)

        new(attributes_hash)
      end

      def self.hash_from(params)
        params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
        params.with_indifferent_access
      end

      def self.ensure_hash(object)
        if object.is_a?(Hash)
          object
        else
          {}
        end
      end

      def with_context(new_context)
        @context = if new_context.is_a?(Hash)
                     OpenStruct.new(new_context)
                   else
                     new_context
                   end

        attributes.each do |_name, value|
          case value
          when Array
            value.each do |v|
              next unless v.respond_to?(:with_context)

              v.with_context(context)
            end
          else
            next unless value.respond_to?(:with_context)

            value.with_context(context)
          end
        end

        self
      end
    end
  end
end
