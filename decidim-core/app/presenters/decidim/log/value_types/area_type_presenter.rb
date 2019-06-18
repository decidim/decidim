# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::AreaType. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class AreaTypePresenter < DefaultPresenter
        # Public: Presents the value as an AreaType. If the area type can
        # be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(area_type.name) if area_type

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.area_type_presenter")
        end

        private

        def area_type
          @area_type ||= Decidim::AreaType.find_by(id: value)
        end
      end
    end
  end
end
