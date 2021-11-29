# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a
      # Decidim::ParticipatoryProcessType. If the type can be found, it shows
      # its title. Otherwise it shows its ID.
      #
      # Returns an HTML-safe String
      class ParticipatoryProcessTypePresenter < Decidim::Log::ValueTypes::DefaultPresenter
        def present
          return unless value
          return h.translated_attribute(type.title) if type

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.participatory_process_type_presenter")
        end

        private

        def type
          @type ||= Decidim::ParticipatoryProcessType.find_by(id: value)
        end
      end
    end
  end
end
