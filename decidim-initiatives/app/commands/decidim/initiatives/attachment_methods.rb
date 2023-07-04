# frozen_string_literal: true

module Decidim
  module Initiatives
    module AttachmentMethods
      include Decidim::AttachmentMethods

      private

      def process_attachments?
        @form.attachment && @form.attachment.file.present? &&
          !@form.attachment.file.is_a?(Decidim::ApplicationUploader)
      end
    end
  end
end
