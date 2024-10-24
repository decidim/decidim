# frozen_string_literal: true

module Decidim
  #
  # Decorator for attachments
  #
  class AttachmentPresenter < SimpleDelegator
    def attachment_file_url
      attachment.attached_uploader(:file).url
    end

    def attachment
      __getobj__
    end
  end
end
