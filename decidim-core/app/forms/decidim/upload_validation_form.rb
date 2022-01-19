# frozen_string_literal: true

module Decidim
  class UploadValidationForm < Decidim::Form
    include Decidim::HasUploadValidations

    attribute :resource, String
    attribute :property, String
    attribute :blob, String

    validate :file

    def file
      org = organization
      PassthruValidator.new(
        attributes: [property],
        to: resource.constantize,
        with: lambda { |record|
          if record.respond_to?(:organization=)
            { organization: record.try(:organization) || org }
          else
            {}
          end
        }
      ).validate_each(self, property.to_sym, blob)
    end

    def organization
      @organization ||= current_organization
    end
  end
end
