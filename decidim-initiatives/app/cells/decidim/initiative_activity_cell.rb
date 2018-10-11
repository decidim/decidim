# frozen_string_literal: true

module Decidim
  # A cell to display when an initiative has been published.
  class InitiativeActivityCell < ActivityCell
    def title
      I18n.t "decidim.initiatives.last_activity.new_initiative"
    end
  end
end
