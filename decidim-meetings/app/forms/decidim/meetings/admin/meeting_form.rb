# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update meetings from Decidim's admin panel.
      class MeetingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String
        translatable_attribute :conciliation_service_description, String
        translatable_attribute :simultaneous_languages, String

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer
        attribute :has_conciliation_service, Boolean
        attribute :has_space_adapted_for_functional_diversity, Boolean
        attribute :has_simultaneous_translations, Boolean

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :address, geocoding: true, if: -> { Decidim.geocoder.present? }
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        validates :conciliation_service_description, translatable_presence: true, if: ->(form) { form.has_conciliation_service? }
        validates :simultaneous_languages, translatable_presence: true, if: ->(form) { form.has_simultaneous_translations? }

        validates :current_component, presence: true
        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }

        validate :scope_belongs_to_participatory_space_scope

        delegate :categories, to: :current_component

        def map_model(model)
          return unless model.categorization

          self.decidim_category_id = model.categorization.decidim_category_id
        end

        alias component current_component

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @decidim_scope_id ? current_participatory_space.scopes.find_by(id: @decidim_scope_id) : current_participatory_space.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the meeting
        def decidim_scope_id
          @decidim_scope_id || scope&.id
        end

        def category
          return unless current_component
          @category ||= categories.find_by(id: decidim_category_id)
        end

        private

        def scope_belongs_to_participatory_space_scope
          errors.add(:decidim_scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
        end
      end
    end
  end
end
