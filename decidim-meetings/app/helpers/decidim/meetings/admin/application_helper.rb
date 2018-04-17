# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        def meeting_organizer_picker_text(form)
          return "" unless form.object.organizer.present?
          return "#{form.object.organizer.name} (@#{form.object.organizer.nickname})" if form.object.organizer.present?
        end
      end
    end
  end
end
