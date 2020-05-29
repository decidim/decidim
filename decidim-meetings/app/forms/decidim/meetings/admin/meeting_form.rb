# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class MeetingForm < MeetingBaseForm
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String

        attribute :organizer_id, Integer
        attribute :organizer_type, String

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :organizer, presence: true, if: ->(form) { form.organizer_id.present? }

        def user_organizers
          return unless organizer_type == "Decidim::UserBaseEntity"

          @user_organizers ||= current_organization.users.find_by(id: organizer_id)
        end

        def user_organizers
          return unless organizer_type == "Decidim::UserBaseEntity"

          @user_organizers ||= current_organization.users.find_by(id: organizer_id)
        end

        def organizer
          @organizer ||= if organizer_id
                           current_organization.users.find_by(id: organizer_id)
                         else
                           current_organization
                         end
        end
      end
    end
  end
end
