# frozen_string_literal: true

module Decidim
  # A cell to display when a conference has been created.
  class ConferenceActivityCell < ActivityCell
    def title
      I18n.t("decidim.conferences.last_activity.new_conference")
    end
  end
end
