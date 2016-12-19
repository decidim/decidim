# frozen_string_literal: true
module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update meetings from Decidim's admin panel.
      class MeetingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :short_description, String
        translatable_attribute :description, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String
        attribute :address, String
        attribute :start_time, DateTime
        attribute :end_time, DateTime
        attribute :decidim_scope_id, Integer

        validates :title, translatable_presence: true
        validates :short_description, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }

        validates :current_feature, presence: true
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }

        def scope
          @scope ||= current_feature.scopes.where(id: decidim_scope_id).first
        end
      end
    end
  end
end
