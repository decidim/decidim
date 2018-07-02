# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      module ValueTypes
        # This class presents the given value as an conference speaker position.
        # Check the `DefaultPresenter` for more info on how value presenters work.
        class SpeakerPositionPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          # Public: Presents the value as an conference speaker position.
          #
          # Returns an HTML-safe String.
          def present
            return if value.blank?
            h.t(value, scope: "decidim.admin.models.conference_speaker.positions", default: value)
          end
        end
      end
    end
  end
end
