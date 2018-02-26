# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingCell < Decidim::ResultCell
      include TranslatableAttributes
      include LayoutHelper

      def show
        render
      end

      private

      def title
        translated_attribute model.title
      end

      def resource_icon
        icon("meetings", remove_icon_class: true, width: 40, height: 70)
      end


    end
  end
end
