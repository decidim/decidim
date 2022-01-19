# frozen_string_literal: true

module Decidim
  class UploadValidationForm < Decidim::Form
    include Decidim::HasUploadValidations

    attribute :resource, String
    # Attribute can not be named as attribute!
    attribute :property, String
    attribute :blob, String
    attribute :klass, String

    validate :file

    def file
      org = organization
      PassthruValidator.new(
        attributes: [property],
        to: resource.constantize,
        with: lambda { |record|
          hash = {}
          hash.merge!(validation_with)
          hash.merge!(organization: record.try(:organization) || org) if record.respond_to?(:organization=)
          hash
        }
      ).validate_each(self, property.to_sym, blob)
    end

    def validation_with
      if form_object_class._validators[property.to_sym].is_a?(Array) && form_object_class._validators[property.to_sym].size.positive?
        passthru = form_object_class._validators[property.to_sym].find { |v| v.is_a?(PassthruValidator) }
        return passthru.options[:with] if passthru && passthru.options[:with].present?
      end
      {}
    end

    def form_object_class
      @form_object_class ||= begin
        klass.constantize if klass.present?
      end
    end

    def organization
      @organization ||= current_organization
    end
  end
end
