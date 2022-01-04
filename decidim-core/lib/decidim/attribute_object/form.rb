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

      def self.infer_model_name
        class_name = name.split("::").last
        return :form if class_name == "Form"

        class_name.chomp("Form").underscore.to_sym
      end

      # Converts the mimiced name to ActiveModel naming.
      def self.model_name
        ActiveModel::Name.new(self, nil, mimicked_model_name.to_s)
      end

      def self.from_model(model)
        attribute_keys = attribute_types.keys + attributes_nested.attributes.keys
        form_attributes = attribute_keys.each_with_object({}) do |key, attrs|
          attrs[key] = model.send(key) if model.respond_to?(key)
        end

        form = new(form_attributes)
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

      def persisted?
        id.present? && id.to_i.positive?
      end

      def to_key
        [id]
      end

      # Required for the active model naming to work correctly to form the HTML
      # class attributes for the form elements (e.g. edit_account instead
      # of edit_account_form).
      def to_model
        self
      end

      def to_param
        id.to_s
      end

      # Use the map_model method within the form implementations to map any
      # custom form-specific attributes from the model to the form.
      def map_model(_model); end

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

      # Although we are running the nested attributes validations through the
      # NestedValidator, we still need to check for the errors in the nested
      # attributes after the main validations are run in case the main
      # validations are adding errors to the nested attributes.
      #
      # This preserves the backwards compatibility with Rectify::Form which
      # did the validations in this order and fails the main record validation
      # in case one of the nested attributes is not valid. This is needed e.g.
      # for the customized component validations (e.g. Budgets component form).
      def valid?(_context = nil)
        super && self.class.attributes_nested.keys.all? do |attr|
          nested = send(attr)
          if nested.respond_to?(:errors)
            nested.errors.none?
          else
            true
          end
        end
      end
    end
  end
end
