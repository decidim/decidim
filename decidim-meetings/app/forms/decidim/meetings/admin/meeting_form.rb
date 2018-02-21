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
        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :address, geocoding: true, if: -> { Decidim.geocoder.present? }
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }

        validates :current_feature, presence: true
        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validate do
          errors.add(:decidim_scope_id, :invalid) unless valid_scope?
        end

        delegate :categories, to: :current_feature

        def map_model(model)
          return unless model.categorization

          self.decidim_category_id = model.categorization.decidim_category_id
        end

        alias feature current_feature

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          return unless current_feature
          @scope ||= decidim_scope_id ? current_feature.scopes.find_by(id: decidim_scope_id) : current_participatory_space.scope
        end

        def category
          return unless current_feature
          @category ||= categories.find_by(id: decidim_category_id)
        end

        private

        def valid_scope?
          return true if current_participatory_space.scope.nil?

          current_participatory_space&.scope == scope || current_participatory_space.scope.ancestor_of?(scope)
        end
      end
    end
  end
end
