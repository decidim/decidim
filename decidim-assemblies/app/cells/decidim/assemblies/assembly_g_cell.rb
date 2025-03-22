# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Grid (:g) assembly card
    # for a given instance of an Assembly
    class AssemblyGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::Assemblies::Engine.routes.url_helpers.assembly_path(model, locale: current_locale)
      end

      def resource_image_url
        model.attached_uploader(:hero_image).url
      end

      def metadata_cell
        "decidim/assemblies/assembly_metadata_g"
      end
    end
  end
end
