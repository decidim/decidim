# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Medium (:m) assembyl card
    # for an given instance of an Assembly
    class AssemblyMCell < Decidim::CardMCell
      include Decidim::ViewHooksHelper

      # Needed for the view hooks
      def current_participatory_space
        model
      end

      private

      def has_image?
        true
      end

      def has_children?
        model.children.any?
      end

      def resource_path
        Decidim::Assemblies::Engine.routes.url_helpers.assembly_path(model)
      end

      def resource_image_path
        model.hero_image.url
      end

      def statuses
        return super unless has_children?

        [:creation_date, :follow, :children_count]
      end

      def creation_date_status
        l(model.creation_date, format: :decidim_short) if model.creation_date
      end

      def children_count_status
        # rubocop: disable Style/StringConcatenation
        content_tag(
          :strong,
          t("layouts.decidim.assemblies.index.children")
        ) + " " + children_assemblies_visible_for_user
        # rubocop: enable Style/StringConcatenation
      end

      def children_assemblies_visible_for_user
        assemblies = model.children.published

        if current_user
          return assemblies.count.to_s if current_user.admin

          assemblies.visible_for(current_user).count.to_s
        else
          assemblies.public_spaces.count.to_s
        end
      end

      def resource_icon
        icon "assemblies", class: "icon--big"
      end

      def has_assembly_type?
        model.assembly_type.present?
      end

      def assembly_type
        translated_attribute model.assembly_type.title
      end
    end
  end
end
