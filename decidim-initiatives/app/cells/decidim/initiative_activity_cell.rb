# frozen_string_literal: true

module Decidim
  class InitiativeActivityCell < ActivityCell
    def title
      I18n.t "decidim.initiatives.last_activity.new_initiative"
    end
  end
end
