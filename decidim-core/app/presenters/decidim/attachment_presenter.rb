# frozen_string_literal: true

module Decidim
  #
  # Decorator for attachments
  #
  class AttachmentPresenter < SimpleDelegator
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers::UrlHelper

    delegate :url, to: :file, prefix: true

    def attachment_file_url
      URI.join(decidim.root_url(host: attachment.attached_to.organization.host), attachment.file_url).to_s
    end

    def attachment
      __getobj__
    end
  end
end
