# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::Assembly. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class AssemblyPresenter < DefaultPresenter
        # Public: Presents the value as a Decidim::Assembly. If the assembly
        # can be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(assembly.title) if assembly

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.assembly_presenter")
        end

        private

        def assembly
          @assembly ||= Decidim::Assembly.find_by(id: value)
        end
      end
    end
  end
end
