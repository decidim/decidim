# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        def meeting_organizer_picker_text(form)
          return "" if form.object.organizer.blank?
          "#{form.object.organizer.name} (@#{form.object.organizer.nickname})"
        end
      end
    end
  end
end
