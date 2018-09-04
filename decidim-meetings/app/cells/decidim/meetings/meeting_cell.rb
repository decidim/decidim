# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the meeting card for an instance of a Meeting
    # the default size is the Medium Card (:m)
    # also available the List Item Card (:list_item)
    class MeetingCell < Decidim::ViewModel
      include MeetingCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :list_item
          "decidim/meetings/meeting_list_item"
        else
          "decidim/meetings/meeting_m"
        end
      end

      def title
        Decidim::Meetings::MeetingPresenter.new(model).title
      end

      def resource_icon
        icon "meetings", remove_icon_class: true, width: 40, height: 70
      end

      def current_component
        model.component
      end

      def current_participatory_space
        model.component.participatory_space
      end

      def component_settings
        model.component.settings
      end

      def component_name
        translated_attribute current_component.name
      end

      def component_type_name
        model.class.model_name.human
      end

      def participatory_space_name
        translated_attribute current_participatory_space.title
      end

      def participatory_space_type_name
        translated_attribute current_participatory_space.model_name.human
      end
    end
  end
end
