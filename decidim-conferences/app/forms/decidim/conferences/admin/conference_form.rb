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
        translatable_attribute :registration_terms, String
        translatable_attribute :custom_link_name, String

        mimic :conference

        attribute :slug, String
        attribute :custom_link_enabled, Boolean
        attribute :custom_link_url, String
        attribute :hashtag, String
        attribute :promoted, Boolean
        attribute :scopes_enabled, Boolean
        attribute :scope_id, Integer
        attribute :hero_image
        attribute :remove_hero_image
        attribute :banner_image
        attribute :remove_banner_image
        attribute :show_statistics, Boolean
        attribute :start_date, Decidim::Attributes::LocalizedDate
        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :registrations_enabled, Boolean
        attribute :available_slots, Integer
        attribute :location, String
        attribute :participatory_processes_ids, Array[Integer]
        attribute :assemblies_ids, Array[Integer]
        attribute :consultations_ids, Array[Integer]

        validates :slug, presence: true, format: { with: Decidim::Conference.slug_format }
        validates :title, :slogan, :description, :short_description, translatable_presence: true

        validate :slug_uniqueness

        validates :custom_link_name, translatable_presence: true, if: ->(form) { form.custom_link_enabled? }
        validates :custom_link_url, presence: true, if: ->(form) { form.custom_link_enabled? }

        validates :registration_terms, translatable_presence: true, if: ->(form) { form.registrations_enabled? }
        validates :available_slots, numericality: { greater_than_or_equal_to: 0 }, if: ->(form) { form.registrations_enabled? }

        validates :hero_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
        validates :banner_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
        validate :available_slots_greater_than_or_equal_to_registrations_count, if: ->(form) { form.registrations_enabled? && form.available_slots.positive? }

        validates :start_date, presence: true, date: { before_or_equal_to: :end_date }
        validates :end_date, presence: true, date: { after_or_equal_to: :start_date }

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.find_by(id: scope_id)
        end

        def processes_for_select
          return unless Decidim.participatory_space_manifests.map(&:name).include?(:participatory_processes)

          @processes_for_select ||= Decidim.find_participatory_space_manifest(:participatory_processes)
                                           .participatory_spaces.call(current_organization)&.order(title: :asc)&.map do |process|
            [
              translated_attribute(process.title),
              process.id
            ]
          end
        end

        def assemblies_for_select
          return unless Decidim.participatory_space_manifests.map(&:name).include?(:assemblies)

          @assemblies_for_select ||= Decidim.find_participatory_space_manifest(:assemblies)
                                            .participatory_spaces.call(current_organization)&.order(title: :asc)&.map do |assembly|
            [
              translated_attribute(assembly.title),
              assembly.id
            ]
          end
        end

        def consultations_for_select
          return unless Decidim.participatory_space_manifests.map(&:name).include?(:consultations)

          @consultations_for_select ||= Decidim.find_participatory_space_manifest(:consultations)
                                               .participatory_spaces.call(current_organization)&.order(title: :asc)&.map do |consultation|
            [
              translated_attribute(consultation.title),
              consultation.id
            ]
          end
        end

        private

        def available_slots_greater_than_or_equal_to_registrations_count
          conference = OrganizationConferences.new(current_organization).query.find_by(slug: slug)
          return true if conference.blank?

          errors.add(:available_slots, :invalid) if available_slots < conference.conference_registrations.count
        end

        def slug_uniqueness
          return unless OrganizationConferences.new(current_organization).query.where(slug: slug).where.not(id: context[:conference_id]).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
