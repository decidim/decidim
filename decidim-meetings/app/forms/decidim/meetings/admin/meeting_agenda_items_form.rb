# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaItemsForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText

        attribute :duration, Integer, default: 0
        attribute :parent_id, Integer
        attribute :position, Integer
        attribute :deleted, Boolean, default: false
        attribute :agenda_item_children, Array[MeetingAgendaItemsForm]

        validates :title, translatable_presence: true, unless: :deleted
        validates :position, numericality: { greater_than_or_equal_to: 0 }, unless: :deleted
        validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0 }

        def to_param
          return id if id.present?

          "meeting-agenda-item-id"
        end

        def to_param_child
          return id if id.present?

          "meeting-agenda-item-child-id"
        end

        def map_model(model)
          self.description = model.presenter.editor_description(all_locales: true)
        end
      end
    end
  end
end
