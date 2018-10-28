# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the Small (:s) meeting card
    # for an given instance of a Meeting
    class MeetingSCell < MeetingMCell
      def title
        translated_attribute model.title
      end

      def meeting_path
        resource_locator(model).path
      end

      def participatory_space_class_name
        model.component.participatory_space.class.model_name.human
      end

      def participatory_space_title
        translated_attribute model.component.participatory_space.title
      end

      def participatory_space_path
        resource_locator(model.component.participatory_space).path
      end
    end
  end
end
