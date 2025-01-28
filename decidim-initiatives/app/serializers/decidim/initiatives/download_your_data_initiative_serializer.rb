# frozen_string_literal: true

module Decidim
  module Initiatives
    class DownloadYourDataInitiativeSerializer < OpenDataInitiativeSerializer
      # Serializes a Debate for download your data feature
      #
      # Remove the author information as it is the same of the user that
      # requested the data
      def serialize
        super.except!(:author)
      end
    end
  end
end
