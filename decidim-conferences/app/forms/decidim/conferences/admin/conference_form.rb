# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conferences from the admin
      # dashboard.
      #
      class ConferenceForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :slogan, String
        translatable_attribute :short_description, String
        translatable_attribute :description, String
        translatable_attribute :objectives, String

        mimic :conference

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
        attribute :start_date, Decidim::Attributes::TimeWithZone
        attribute :end_date, Decidim::Attributes::TimeWithZone

        validates :slug, presence: true, format: { with: Decidim::Conference.slug_format }
        validates :title, :slogan, :description, :short_description, translatable_presence: true

        validate :slug_uniqueness

        validates :hero_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
        validates :banner_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.find_by(id: scope_id)
        end

        private

        def slug_uniqueness
          return unless OrganizationConferences.new(current_organization).query.where(slug: slug).where.not(id: context[:conference_id]).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
