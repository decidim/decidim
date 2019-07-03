# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::Conference. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class ConferencePresenter < DefaultPresenter
        # Public: Presents the value as a Decidim::Conference. If the conference
        # can be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(conference.title) if conference

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.conference_presenter")
        end

        private

        def conference
          @conference ||= Decidim::Conference.find_by(id: value)
        end
      end
    end
  end
end
