# frozen_string_literal: true

module Decidim
  module Meetings
    class DownloadYourDataRegistrationSerializer < BaseDownloadYourDataSerializer
      # Serializes a registration for download your data
      def serialize
        super.merge({
                      code: resource.code,
                      validated_at: resource.validated_at,
                      public_participation: resource.public_participation
                    })
      end
    end
  end
end
