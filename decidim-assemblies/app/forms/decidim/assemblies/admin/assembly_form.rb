# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assemblies from the admin
      # dashboard.
      #
      class AssemblyForm < Form
        include TranslatableAttributes

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

        validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }
        validates :title, :subtitle, :description, :short_description, translatable_presence: true
        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }

        validate :slug_uniqueness

        validates :hero_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
        validates :banner_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.where(id: scope_id).first
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
