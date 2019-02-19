# frozen-string_literal: true

module Decidim
  class AttachmentCreatedEvent < Decidim::Events::SimpleEvent
    i18n_attributes :resource_url

    def resource_path
      @resource.url
    end

    def resource_url
      resource_locator.url
    end

    def resource_text
      translated_attribute(
        resource.try(:description) ||
          resource.try(:body)
      )
    end

    private

    def resource
      @resource.attached_to
    end
  end
end
