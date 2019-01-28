# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Medium (:m) assembyl card
    # for an given instance of an Assembly
    class AssemblyMCell < Decidim::CardMCell
      include Decidim::Assemblies::Engine.routes.url_helpers
      include Decidim::ViewHooksHelper

      # Needed for the view hooks
      def current_participatory_space
        model
      end

      private

      def has_image?
        true
      end

      def resource_path
        assembly_path(model)
      end

      def resource_image_path
        model.hero_image.url
      end

      def statuses
        [:creation_date, :follow]
      end

      def resource_icon
        icon "assemblies", class: "icon--big"
      end

      def has_assembly_type?
        model.assembly_type.present?
      end

      def assembly_type
        if model.assembly_type == "others"
          translated_attribute(model.assembly_type_other)
        else
          t("assembly_types.#{model.assembly_type}", scope: "decidim.assemblies").to_s
        end
      end
    end
  end
end
