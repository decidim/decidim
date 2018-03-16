# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingCell < Decidim::Meetings::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model
      end

      private

      def title
        translated_attribute model.title
      end

      def description
        decidim_sanitize meeting_description(model)
      end

      def card_size
        case @options[:size]
        when :h
          "decidim/meetings/meeting_h"
        else
          "decidim/meetings/meeting_m"
        end
      end

      def resource_icon
        icon "meetings", remove_icon_class: true, width: 40, height: 70
      end

      def resource_path
        resource_locator(model).path
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
