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
        include Decidim::HasTaxonomyFormAttributes

        mimic :participatory_process

        translatable_attribute :announcement, Decidim::Attributes::RichText
        translatable_attribute :description, Decidim::Attributes::RichText
        translatable_attribute :developer_group, String
        translatable_attribute :local_area, String
        translatable_attribute :meta_scope, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :participatory_structure, String
        translatable_attribute :subtitle, String
        translatable_attribute :short_description, Decidim::Attributes::RichText
        translatable_attribute :title, String
        translatable_attribute :target, String

        attribute :hashtag, String
        attribute :slug, String

        attribute :participatory_process_group_id, Integer
        attribute :related_process_ids, Array[Integer]
        attribute :weight, Integer, default: 0

        attribute :private_space, Boolean
        attribute :promoted, Boolean

        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :start_date, Decidim::Attributes::LocalizedDate

        attribute :hero_image
        attribute :remove_hero_image, Boolean, default: false

        validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }

        validate :slug_uniqueness

        validates :title, :subtitle, :description, :short_description, translatable_presence: true

        validates :hero_image, passthru: { to: Decidim::ParticipatoryProcess }

        validates :weight, presence: true

        alias organization current_organization

        def map_model(model)
          self.participatory_process_group_id = model.decidim_participatory_process_group_id
          self.related_process_ids = model.linked_participatory_space_resources(:participatory_process, "related_processes").pluck(:id)
          self.description = model.presenter.editor_description(all_locales: true)
          self.short_description = model.presenter.editor_short_description(all_locales: true)
          @processes = Decidim::ParticipatoryProcess.where(organization: model.organization).where.not(id: model.id)
        end

        def participatory_space_manifest
          :participatory_processes
        end

        def participatory_process_group
          Decidim::ParticipatoryProcessGroup.find_by(id: participatory_process_group_id)
        end

        def processes
          @processes ||= Decidim::ParticipatoryProcess.where(organization: current_organization)
        end

        private

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
