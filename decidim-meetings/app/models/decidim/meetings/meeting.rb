# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasFeature
      include Decidim::HasReference
      include Decidim::HasScope
      include Decidim::HasCategory

      feature_manifest_name "meetings"

      validates :title, presence: true

      geocoded_by :address

      def closed?
        closed_at.present?
      end
    end
  end
end
