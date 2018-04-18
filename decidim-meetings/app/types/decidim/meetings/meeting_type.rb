# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingType = GraphQL::ObjectType.define do
      name "Meeting"
      description "A meeting"

      interfaces [
        Decidim::Comments::CommentableInterface,
        Decidim::Core::CategorizableInterface,
        Decidim::Core::ScopableInterface,
        Decidim::Core::AttachableInterface
      ]

      field :id, !types.ID
      field :reference, !types.String
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this meeting."
      field :startTime, !Decidim::Core::DateTimeType, "The time this meeting starts", property: :start_time
      field :endTime, !Decidim::Core::DateTimeType, "The time this meeting ends", property: :end_time
      field :closed, !types.Boolean, "Whether this meeting is closed or not."
      field :remainingSlots, types.Int, "Amount of slots available for this meeting", property: :remaining_slots
      field :address, types.String, "The physical address of this meeting"
      field :closingReport, types.String, "The closing report of this meeting.", property: :closing_report

      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this meeting" do
        resolve ->(meeting, _args, _ctx) {
          [meeting.latitude, meeting.longitude]
        }
      end
    end
  end
end
