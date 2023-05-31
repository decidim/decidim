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

        CREATED_BY = %w(city_council public others).freeze

        mimic :assembly

        translatable_attribute :composition, String
        translatable_attribute :closing_date_reason, String
        translatable_attribute :created_by_other, String
        translatable_attribute :description, String
        translatable_attribute :developer_group, String
        translatable_attribute :internal_organisation, String
        translatable_attribute :local_area, String
        translatable_attribute :meta_scope, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :participatory_structure, String
        translatable_attribute :purpose_of_action, String
        translatable_attribute :short_description, String
        translatable_attribute :special_features, String
        translatable_attribute :subtitle, String
        translatable_attribute :target, String
        translatable_attribute :title, String
        translatable_attribute :announcement, String

        attribute :created_by, String
        attribute :facebook_handler, String
        attribute :github_handler, String
        attribute :hashtag, String
        attribute :instagram_handler, String
        attribute :slug, String
        attribute :twitter_handler, String
        attribute :youtube_handler, String

        attribute :decidim_assemblies_type_id, Integer
        attribute :area_id, Integer
        attribute :parent_id, Integer
        attribute :participatory_processes_ids, Array[Integer]
        attribute :scope_id, Integer
        attribute :weight, Integer, default: 0

        attribute :is_transparent, Boolean
        attribute :promoted, Boolean
        attribute :private_space, Boolean
        attribute :show_statistics, Boolean
        attribute :scopes_enabled, Boolean

        attribute :closing_date, Decidim::Attributes::LocalizedDate
        attribute :creation_date, Decidim::Attributes::LocalizedDate
        attribute :duration, Decidim::Attributes::LocalizedDate
        attribute :included_at, Decidim::Attributes::LocalizedDate

        attribute :banner_image
        attribute :hero_image
        attribute :remove_banner_image, Boolean, default: false
        attribute :remove_hero_image, Boolean, default: false

        validates :area, presence: true, if: proc { |object| object.area_id.present? }

        validates :parent, presence: true, if: ->(form) { form.parent.present? }
        validate :ensure_parent_cannot_be_child, if: ->(form) { form.parent.present? }

        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }
        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }

        validate :slug_uniqueness
        validate :same_type_organization, if: ->(form) { form.decidim_assemblies_type_id }

        validates :created_by_other, translatable_presence: true, if: ->(form) { form.created_by == "others" }
        validates :title, :subtitle, :description, :short_description, translatable_presence: true

        validates :banner_image, passthru: { to: Decidim::Assembly }
        validates :hero_image, passthru: { to: Decidim::Assembly }

        validates :weight, presence: true

        alias organization current_organization

        def ensure_parent_cannot_be_child
          return if id.blank?

          available_assemblies = Decidim::Assemblies::ParentAssembliesForSelect.for(current_organization, Assembly.find(id))
          errors.add(:parent, :invalid) unless available_assemblies.include? parent
        end

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.find_by(id: scope_id)
        end

        def area
          @area ||= current_organization.areas.find_by(id: area_id)
        end

        def assembly_types_for_select
          @assembly_types_for_select ||= organization_assembly_types
                                             &.map { |type| [translated_attribute(type.title), type.id] }
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

        def assembly_type
          AssembliesType.find_by(id: decidim_assemblies_type_id)
        end

        private

        def organization_assembly_types
          AssembliesType.where(organization: current_organization)
        end

        def organization_participatory_processes
          Decidim.find_participatory_space_manifest(:participatory_processes)
                 .participatory_spaces.call(current_organization)
        end

        def organization_assemblies
          OrganizationAssemblies.new(current_organization).query
        end

        def slug_uniqueness
          return unless organization_assemblies
                        .where(slug:)
                        .where.not(id: context[:assembly_id])
                        .any?

          errors.add(:slug, :taken)
        end

        def same_type_organization
          return unless assembly_type
          return if assembly_type.organization == current_organization

          errors.add(:assembly_type, :invalid)
        end
      end
    end
  end
end
