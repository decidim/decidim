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

        translatable_attribute :title, String
        translatable_attribute :subtitle, String
        translatable_attribute :description, String
        translatable_attribute :short_description, String
        translatable_attribute :meta_scope, String
        translatable_attribute :developer_group, String
        translatable_attribute :local_area, String
        translatable_attribute :target, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :participatory_structure, String
        translatable_attribute :purpose_of_action, String
        translatable_attribute :assembly_type_other, String
        translatable_attribute :created_by_other, String
        translatable_attribute :closing_date_reason, String
        translatable_attribute :internal_organisation, String
        translatable_attribute :special_features, String

        mimic :assembly

        attribute :slug, String
        attribute :hashtag, String
        attribute :promoted, Boolean
        attribute :scopes_enabled, Boolean
        attribute :scope_id, Integer
        attribute :hero_image
        attribute :remove_hero_image
        attribute :banner_image
        attribute :remove_banner_image
        attribute :show_statistics, Boolean
        attribute :area_id, Integer
        attribute :assembly_type, String
        attribute :creation_date, Decidim::Attributes::TimeWithZone
        attribute :created_by, String
        attribute :duration, Decidim::Attributes::TimeWithZone
        attribute :included_at, Decidim::Attributes::TimeWithZone
        attribute :closing_date, Decidim::Attributes::TimeWithZone
        attribute :is_open, Boolean
        attribute :is_public, Boolean
        attribute :is_transparent, Boolean
        attribute :twitter_handler, String
        attribute :facebook_handler, String
        attribute :instagram_handler, String
        attribute :youtube_handler, String
        attribute :github_handler, String

        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }
        validates :title, :subtitle, :description, :short_description, translatable_presence: true
        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }
        validates :area, presence: true, if: proc { |object| object.area_id.present? }

        validates :assembly_type_other, translatable_presence: true, if: ->(form) { form.assembly_type == "others" }
        validates :created_by_other, translatable_presence: true, if: ->(form) { form.created_by == "others" }

        validates :is_public, presence: true, if: ->(form) { !form.is_open }
        validates :is_transparent, presence: true, if: ->(form) { !form.is_public }
        validates :special_features, translatable_presence: true, if: ->(form) { !form.is_open }

        validate :slug_uniqueness

        validates :hero_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
        validates :banner_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.where(id: scope_id).first
        end

        def area
          @area ||= current_organization.areas.where(id: area_id).first
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
          CREATED_BY.map do |by|
            [
              I18n.t("created_by.#{by}", scope: "decidim.assemblies"),
              by
            ]
          end
        end

        private

        def slug_uniqueness
          return unless OrganizationAssemblies.new(current_organization).query.where(slug: slug).where.not(id: context[:assembly_id]).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
