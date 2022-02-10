# frozen_string_literal: true

module Decidim
  # A form object used to handle upload validations, this is used when user is
  # adding files to dropzone in upload modal.
  class UploadValidationForm < Decidim::Form
    include Decidim::HasUploadValidations

    attribute :resource_class, String
    # Property is named as attribute in upload modal and passthru validator, but it
    # cannot be named as attribute here.
    attribute :property, String
    attribute :blob, String
    attribute :form_class, String

    validates :resource_class, presence: true
    validates :property, presence: true
    validates :blob, presence: true
    validate :file, if: ->(form) { form.resource_class.present? && form.property.present? && form.blob.present? }

    def file
      org = organization
      PassthruValidator.new(
        attributes: [property],
        to: resource_class.constantize,
        with: lambda { |record|
          validate_with.tap do |hash|
            hash.merge!(organization: record.try(:organization) || org) if !hash[:organization] && record.respond_to?(:organization=)
          end
        }
      ).validate_each(self, property.to_sym, blob)
    end

    private

    def validate_with
      if form_object_class && form_object_class._validators[property.to_sym].is_a?(Array) && form_object_class._validators[property.to_sym].size.positive?
        passthru = form_object_class._validators[property.to_sym].find { |v| v.is_a?(PassthruValidator) }
        return passthru.options[:with] if passthru && passthru.options[:with].present?
      end
      {}
    end

    def form_object_class
      @form_object_class ||= begin
        form_class.constantize if form_class.present?
      rescue NameError
        nil
      end
    end

    alias organization current_organization
  end
end
