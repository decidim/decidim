# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class serializes an Assembly so it can be exported to CSV for the Open Data feature.
    class OpenDataAssemblySerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with an Assembly instance.
      def initialize(assembly)
        @assembly = assembly
      end

      # Public: Exports a hash with the serialized data for this assembly.
      def serialize
        {
          id: assembly.id,
          slug: assembly.slug,
          hashtag: assembly.hashtag,
          decidim_organization_id: assembly.decidim_organization_id,
          title: assembly.title,
          subtitle: assembly.subtitle,
          weight: assembly.weight,
          short_description: assembly.short_description,
          description: assembly.description,
          remote_hero_image_url: Decidim::Assemblies::AssemblyPresenter.new(assembly).hero_image_url,
          remote_banner_image_url: Decidim::Assemblies::AssemblyPresenter.new(assembly).banner_image_url,
          promoted: assembly.promoted,
          developer_group: assembly.developer_group,
          meta_scope: assembly.meta_scope,
          local_area: assembly.local_area,
          target: assembly.target,
          decidim_scope_id: assembly.decidim_scope_id,
          paticipatory_scope: assembly.participatory_scope, # intentionally misspelled
          participatory_structure: assembly.participatory_structure,
          scopes_enabled: assembly.scopes_enabled,
          private_space: assembly.private_space,
          reference: assembly.reference,
          purpose_of_action: assembly.purpose_of_action,
          composition: assembly.composition,
          duration: assembly.duration,
          participatory_scope: assembly.participatory_scope,
          included_at: assembly.included_at,
          closing_date: assembly.closing_date,
          created_by: assembly.created_by,
          creation_date: assembly.creation_date,
          closing_date_reason: assembly.closing_date_reason,
          internal_organisation: assembly.internal_organisation,
          is_transparent: assembly.is_transparent,
          special_features: assembly.special_features,
          twitter_handler: assembly.twitter_handler,
          instagram_handler: assembly.instagram_handler,
          facebook_handler: assembly.facebook_handler,
          youtube_handler: assembly.youtube_handler,
          github_handler: assembly.github_handler,
          created_by_other: assembly.created_by_other,
          decidim_assemblies_type_id: assembly.decidim_assemblies_type_id,
          area: {
            id: assembly.area.try(:id),
            name: assembly.area.try(:name) || empty_translatable
          },
          scope: {
            id: assembly.scope.try(:id),
            name: assembly.scope.try(:name) || empty_translatable
          },

          assembly_categories: serialize_categories,
          announcement: assembly.announcement
        }
      end

      private

      attr_reader :assembly
      alias resource assembly

      def serialize_categories
        return unless assembly.categories.first_class.any?

        assembly.categories.first_class.map do |category|
          {
            id: category.try(:id),
            name: category.try(:name),
            description: category.try(:description),
            parent_id: category.try(:parent_id),
            subcategories: serialize_subcategories(category.subcategories)
          }
        end
      end

      def serialize_subcategories(subcategories)
        return unless subcategories.any?

        subcategories.map do |subcategory|
          {
            id: subcategory.try(:id),
            name: subcategory.try(:name),
            description: subcategory.try(:description),
            parent_id: subcategory.try(:parent_id)
          }
        end
      end
    end
  end
end
