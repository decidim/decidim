# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Grid (:g) assembly card
    # for a given instance of an Assembly
    class AssemblyGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::Assemblies::Engine.routes.url_helpers.assembly_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def metadata_cell
        "decidim/assemblies/assembly_metadata_g"
      end
    end
  end
end
