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
    end

    def organization
      @organization ||= current_organization
    end
  end
end
