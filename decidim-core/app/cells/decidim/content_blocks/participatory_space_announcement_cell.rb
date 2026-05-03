# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceAnnouncementCell < BaseCell
      def show
        return if announcement_cell.blank_content?

        render
      end

      def announcement_cell
        @announcement_cell ||= cell("decidim/announcement", model.settings.announcement)
      end
    end
  end
end
