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
      if resource.respond_to?(:description)
        translated(resource, :description)
      elsif resource.respond_to?(:body)
        translated(resource, :body)
      end
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
