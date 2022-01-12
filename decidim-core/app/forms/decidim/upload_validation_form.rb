# frozen_string_literal: true

module Decidim
  class UploadValidationForm < Decidim::Form
    include Decidim::HasUploadValidations

    attribute :resource, String
    attribute :attribute, String
    attribute :blob, String

    validate :file

    def file
      PassthruValidator.new(attributes: [attribute], to: resource.constantize).validate_each(self, attribute.to_sym, blob)
      # org = organization
      # PassthruValidator.new(
      #   attributes: [attribute],
      #   to: resource.constantize,
      #   with: lambda { |record|
      #     record.organization = org if record.respond_to?(:organization=) && !record.organization
      #   }
      # ).validate_each(self, attribute.to_sym, blob)
    end

    def organization
      @organization ||= current_organization
    end
  end
end
