# frozen-string_literal: true

module Decidim
  class AttachmentCreatedEvent < Decidim::Events::SimpleEvent
    i18n_attributes :attached_to_url

    def resource_path
      @resource.url
    end

    def resource_url
      attached_to_url
    end

    def resource_text
      translated_attribute(
        resource.try(:description) ||
          resource.try(:body)
      )
    end

    def url_host=(host)
      @url_host = host
    end

    def url_host
      @url_host
    end

    private

    def attached_to_url
      resource_locator.url
    end

    def resource
      @resource.attached_to
    end
  end
end
