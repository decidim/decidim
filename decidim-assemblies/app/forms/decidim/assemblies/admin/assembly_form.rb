# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assemblies from the admin
      # dashboard.
      #
      class AssemblyForm < Form
        include TranslatableAttributes

        ASSEMBLY_TYPES = %w(government executive consultative_advisory participatory working_group commission others).freeze
        CREATED_BY = %w(city_council public others).freeze

        mimic :assembly

        translatable_attribute :assembly_type_other, String
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

        attribute :assembly_type, String
        attribute :created_by, String
        attribute :facebook_handler, String
        attribute :github_handler, String
        attribute :hashtag, String
        attribute :instagram_handler, String
        attribute :slug, String
        attribute :twitter_handler, String
        attribute :youtube_handler, String

        attribute :area_id, Integer
        attribute :parent_id, Integer
        attribute :participatory_processes_ids, Array[Integer]
        attribute :scope_id, Integer

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
        attribute :remove_banner_image
        attribute :remove_hero_image

        validates :area, presence: true, if: proc { |object| object.area_id.present? }
        validates :parent, presence: true, if: ->(form) { form.parent_id.present? }
        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }
        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }

        validate :slug_uniqueness

        validates :assembly_type_other, translatable_presence: true, if: ->(form) { form.assembly_type == "others" }
        validates :created_by_other, translatable_presence: true, if: ->(form) { form.created_by == "others" }
        validates :title, :subtitle, :description, :short_description, translatable_presence: true

        validates :banner_image,
                  file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                  file_content_type: { allow: ["image/jpeg", "image/png"] }
        validates :hero_image,
                  file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                  file_content_type: { allow: ["image/jpeg", "image/png"] }

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
          ASSEMBLY_TYPES.map do |type|
            [
              I18n.t("assembly_types.#{type}", scope: "decidim.assemblies"),
              type
            ]
          end
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
                        .where(slug: slug)
                        .where.not(id: context[:assembly_id])
                        .any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
