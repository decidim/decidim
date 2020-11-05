# frozen_string_literal: true

module Decidim
  module Conferences
    # The data store for an Invite in the Decidim::Conferences component.
    class MediaLink < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title

      belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"

      def self.log_presenter_class_for(_log)
        Decidim::Conferences::AdminLog::MediaLinkPresenter
      end
    end
  end
end
