# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assemblies from the admin
      # dashboard.
      #
      class AssemblyForm < Form
        include TranslatableAttributes

        TYPE_OF_ASSEMBLY = %w(government executive consultative_advisory participatory working_group commission others).freeze
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
        translatable_attribute :type_of_assembly_other, String
        translatable_attribute :created_by_other, String
        translatable_attribute :closing_date_reason, String
        translatable_attribute :internal_organisation, String

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
        attribute :type_of_assembly, String
        attribute :date_created, Decidim::Attributes::TimeWithZone
        attribute :created_by, String
        attribute :duration, Decidim::Attributes::TimeWithZone
        attribute :date_of_inclusion, Decidim::Attributes::TimeWithZone
        attribute :has_closed, Boolean
        attribute :closing_date, Decidim::Attributes::TimeWithZone

        validates :slug, presence: true, format: { with: Decidim::Assembly.slug_format }
        validates :title, :subtitle, :description, :short_description, translatable_presence: true
        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }
        validates :area, presence: true, if: proc { |object| object.area_id.present? }

        validates :closing_date, presence: true, if: ->(form) { form.has_closed }
        validates :closing_date_reason, translatable_presence: true, if: ->(form) { form.has_closed }

        validates :type_of_assembly_other, translatable_presence: true, if: ->(form) { form.type_of_assembly == "others" }
        validates :created_by_other, translatable_presence: true, if: ->(form) { form.created_by == "others" }

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

        def types_of_assembly_for_select
          TYPE_OF_ASSEMBLY.map do |type|
            [
              I18n.t(type.downcase, scope: "decidim.assemblies.types_of_assembly"),
              type
            ]
          end
        end

        def created_by_for_select
          CREATED_BY.map do |by|
            [
              I18n.t(by.downcase, scope: "decidim.assemblies.created_by"),
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
