# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :agenda_items, Array[MeetingAgendaItemsForm]
        attribute :visible, Boolean

        validates :title, translatable_presence: true
        validate :agenda_duration_too_long
        validate :agenda_items_duration_too_long

        def map_model(model)
          self.agenda_items = model.agenda_items.first_class.map do |agenda_item|
            MeetingAgendaItemsForm.from_model(agenda_item)
          end
        end

        private

        def meeting
          @meeting ||= context[:meeting]
        end

        def agenda_duration_too_long
          if agenda_duration > meeting.meeting_duration
            difference = agenda_duration - meeting.meeting_duration
            errors.add(:base, :too_many_minutes, count: difference)
          end
        end

        def agenda_duration
          @agenda_duration ||= agenda_items.sum(&:duration)
        end

        def agenda_items_duration_too_long
          agenda_items.each do |agenda_item|
            children_duration = agenda_item.agenda_item_children.sum(&:duration)

            if children_duration > agenda_item.duration
              difference = children_duration - agenda_item.duration
              errors.add(:base, :too_many_minutes_child, parent_title: translated_attribute(agenda_item.title), count: difference)
            end
          end
        end
      end
    end
  end
end
