# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory processes from the admin
      # dashboard.
      #
      class ParticipatoryProcessForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        mimic :participatory_process

        translatable_attribute :announcement, String
        translatable_attribute :description, String
        translatable_attribute :developer_group, String
        translatable_attribute :local_area, String
        translatable_attribute :meta_scope, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :participatory_structure, String
        translatable_attribute :subtitle, String
        translatable_attribute :short_description, String
        translatable_attribute :title, String
        translatable_attribute :target, String

        attribute :hashtag, String
        attribute :slug, String

        attribute :area_id, Integer
        attribute :participatory_process_group_id, Integer
        attribute :scope_id, Integer
        attribute :related_process_ids, Array[Integer]
        attribute :scope_type_max_depth_id, Integer
        attribute :weight, Integer, default: 0

        attribute :private_space, Boolean
        attribute :promoted, Boolean
        attribute :scopes_enabled, Boolean
        attribute :show_metrics, Boolean
        attribute :show_statistics, Boolean
        attribute :participatory_process_type_id, Integer

        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :start_date, Decidim::Attributes::LocalizedDate

        attribute :banner_image
        attribute :hero_image
        attribute :remove_banner_image, Boolean, default: false
        attribute :remove_hero_image, Boolean, default: false

        validates :area, presence: true, if: proc { |object| object.area_id.present? }
        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }
        validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }

        validate :slug_uniqueness

        validates :title, :subtitle, :description, :short_description, translatable_presence: true

        validates :banner_image, passthru: { to: Decidim::ParticipatoryProcess }
        validates :hero_image, passthru: { to: Decidim::ParticipatoryProcess }

        validates :weight, presence: true

        alias organization current_organization

        def map_model(model)
          self.scope_id = model.decidim_scope_id
          self.participatory_process_group_id = model.decidim_participatory_process_group_id
          self.participatory_process_type_id = model.decidim_participatory_process_type_id
          self.related_process_ids = model.linked_participatory_space_resources(:participatory_process, "related_processes").pluck(:id)
          @processes = Decidim::ParticipatoryProcess.where(organization: model.organization).where.not(id: model.id)
        end

        def scope
          @scope ||= current_organization.scopes.find_by(id: scope_id)
        end

        def scope_type_max_depth
          @scope_type_max_depth ||= current_organization.scope_types.find_by(id: scope_type_max_depth_id)
        end

        def area
          @area ||= current_organization.areas.find_by(id: area_id)
        end

        def participatory_process_group
          Decidim::ParticipatoryProcessGroup.find_by(id: participatory_process_group_id)
        end

        def participatory_process_type
          Decidim::ParticipatoryProcessType.find_by(id: participatory_process_type_id)
        end

        def processes
          @processes ||= Decidim::ParticipatoryProcess.where(organization: current_organization)
        end

        def participatory_process_types_for_select
          @participatory_process_types_for_select ||= participatory_process_types.map do |type|
            [translated_attribute(type.title), type.id]
          end
        end

        private

        def participatory_process_types
          Decidim::ParticipatoryProcessType.where(organization: current_organization)
        end

        def organization_participatory_processes
          OrganizationParticipatoryProcesses.new(current_organization).query
        end

        def slug_uniqueness
          return unless organization_participatory_processes
                        .where(slug:)
                        .where.not(id: context[:process_id])
                        .any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
