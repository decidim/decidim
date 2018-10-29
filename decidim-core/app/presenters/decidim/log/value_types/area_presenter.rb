# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::Area. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class AreaPresenter < DefaultPresenter
        # Public: Presents the value as a Decidim::Area. If the area can
        # be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(area.name) if area

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.area_presenter")
        end

        private

        def area
          @area ||= Decidim::Area.find_by(id: value)
        end
      end
    end
  end
end
