# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a Decidim::Taxonomy. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class TaxonomyPresenter < DefaultPresenter
        # Public: Presents the value as a Decidim::Taxonomy. If the taxonomy can
        # be found, it shows its title. Otherwise it shows its ID.
        #
        # Returns an HTML-safe String.
        def present
          return unless value
          return h.translated_attribute(taxonomy.name) if taxonomy

          I18n.t("not_found", id: value, scope: "decidim.log.value_types.taxonomy_presenter")
        end

        private

        def taxonomy
          @taxonomy ||= Decidim::Taxonomy.find_by(id: value)
        end
      end
    end
  end
end
