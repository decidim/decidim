# frozen_string_literal: true

module Decidim
  class UploadValidationForm < Decidim::Form
    include Decidim::HasUploadValidations

    attribute :resource, String
    attribute :attribute, String
    attribute :blob, String

    validate :file

    def file
      PassthruValidator.new(attributes: [attribute], to: Decidim::User).validate_each(self, attribute, blob)
    end

    def organization
      # HAXX
      Decidim::Organization.first
    end
  end
end
