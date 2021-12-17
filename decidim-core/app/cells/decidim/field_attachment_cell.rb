# frozen_string_literal: true

module Decidim
  class FieldAttachmentCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include ERB::Util

    private

    def field_id
      @field_id ||= "attachments_#{SecureRandom.uuid}"
    end
  end
end
