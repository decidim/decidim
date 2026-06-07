# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assemblies from the admin
      # dashboard.
      #
      class AssemblyForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations
        include Decidim::HasTaxonomyFormAttributes

        CREATED_BY = %w(city_council public others).freeze

        mimic :assembly

        translatable_attribute :composition, Decidim::Attributes::RichText
        translatable_attribute :closing_date_reason, Decidim::Attributes::RichText
        translatable_attribute :created_by_other, String
        translatable_attribute :description, Decidim::Attributes::RichText
        translatable_attribute :developer_group, String
        translatable_attribute :internal_organisation, Decidim::Attributes::RichText
        translatable_attribute :local_area, String
        translatable_attribute :meta_scope, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :participatory_structure, String
        translatable_attribute :purpose_of_action, Decidim::Attributes::RichText
        translatable_attribute :short_description, Decidim::Attributes::RichText
        translatable_attribute :special_features, Decidim::Attributes::RichText
        translatable_attribute :subtitle, String
        translatable_attribute :target, String
        translatable_attribute :title, String

        attribute :created_by, String
        attribute :facebook_handler, String
        attribute :github_handler, String
        attribute :instagram_handler, String
        attribute :slug, String
        attribute :twitter_handler, String
        attribute :youtube_handler, String

        attribute :parent_id, Integer
        attribute :participatory_processes_ids, Array[Integer]
        attribute :weight, Integer, default: 0

        attribute :access_mode, String, default: :open
        attribute :has_members, Boolean
        attribute :promoted, Boolean

        attribute :closing_date, Decidim::Attributes::LocalizedDate
        attribute :creation_date, Decidim::Attributes::LocalizedDate
        attribute :duration, Decidim::Attributes::LocalizedDate
        attribute :included_at, Decidim::Attributes::LocalizedDate

        attribute :hero_image
        attribute :remove_hero_image, Boolean, default: false

        validates :parent, presence: true, if: ->(form) { form.parent.present? }
        validate :ensure_parent_cannot_be_child, if: ->(form) { form.parent.present? }

        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }

        validate :slug_uniqueness

        validates :created_by_other, translatable_presence: true, if: ->(form) { form.created_by == "others" }
        validates :title, :subtitle, :description, :short_description, translatable_presence: true

        validates :hero_image, passthru: { to: Decidim::Assembly }

        validates :weight, presence: true

        validates :access_mode, presence: true, inclusion: { in: Decidim::Assembly.access_modes.keys }
        validate :ensure_access_mode_for_has_members

        alias organization current_organization

        def participatory_space_manifest
          :assemblies
        end

        def ensure_parent_cannot_be_child
          return if id.blank?

          available_assemblies = Decidim::Assemblies::ParentAssembliesForSelect.for(current_organization, Assembly.find(id))
          errors.add(:parent, :invalid) unless available_assemblies.include? parent
        end

        def created_by_for_select
          CREATED_BY.map do |creator|
            [
              I18n.t("created_by.#{creator}", scope: "decidim.assemblies"),
              creator
            ]
          end
        end

        def parent
          @parent ||= organization_assemblies.find_by(id: parent_id)
        end

        def processes_for_select
          @processes_for_select ||= organization_participatory_processes
                                        &.map { |pp| [translated_attribute(pp.title), pp.id] }
                                        &.sort_by { |arr| arr[0] }
        end

        private

        def organization_participatory_processes
          Decidim.find_participatory_space_manifest(:participatory_processes)
                 .participatory_spaces.call(current_organization)
        end

        def organization_assemblies
          OrganizationAssemblies.new(current_organization).query
        end

        def slug_uniqueness
          return unless organization_assemblies
                        .with_deleted
                        .where(slug:)
                        .where.not(id: context[:assembly_id])
                        .any?

          errors.add(:slug, :taken)
        end

        def ensure_access_mode_for_has_members
          self.access_mode = :open if has_members == false
        end
      end
    end
  end
end
