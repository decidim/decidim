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
        validates :address, geocoding: true, if: ->(form) { form.address.present? }
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }

        validates :current_feature, presence: true
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }

        def process_scope
          current_feature.participatory_process.scope
        end

        def scope
          return unless current_feature
          @scope ||= process_scope || current_feature.scopes.where(id: decidim_scope_id).first
        end

        def category
          return unless current_feature
          @category ||= current_feature.categories.where(id: decidim_category_id).first
        end
      end
    end
  end
end
