# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference registration types from the admin dashboard.
      class RegistrationTypeForm < Form
        include TranslatableAttributes
        include Decidim::ApplicationHelper

        mimic :conference_registration_type

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :weight, Integer
        attribute :price, Decimal
        attribute :conference_meeting_ids, Array[Integer]

        validates :title, :description, :weight, presence: true
        validates :weight, numericality: { greater_than_or_equal_to: 0 }
        validates :price, numericality: { greater_than_or_equal_to: 0 }, if: ->(form) { form.price.present? }

        def meetings
          meeting_components = current_participatory_space.components.where(manifest_name: "meetings")
          @meetings ||= Decidim::ConferenceMeeting.where(component: meeting_components)
                                                   &.order(title: :asc)
                                                   &.map do |meeting|
                                                     OpenStruct.new(
                                                       title: present(meeting).title,
                                                       value: meeting.id
                                                     )
                                                   end
        end

        def conference_meetings
          meeting_components = current_participatory_space.components.where(manifest_name: "meetings")
          return unless meeting_components || conference_meeting_ids.delete("").present?

          @conference_meetings ||= Decidim::ConferenceMeeting.where(component: meeting_components).where(id: conference_meeting_ids)
        end
      end
    end
  end
end
