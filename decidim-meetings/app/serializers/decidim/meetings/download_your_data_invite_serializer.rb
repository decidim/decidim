# frozen_string_literal: true

module Decidim
  module Meetings
    class DownloadYourDataInviteSerializer < BaseDownloadYourDataSerializer
      # Serializes an invite for download your data
      def serialize
        super.merge({
          sent_at: resource.sent_at,
          accepted_at: resource.accepted_at,
          rejected_at: resource.rejected_at,
        })
      end
    end
  end
end
