# frozen_string_literal: true

module Decidim
  # A cell to display when an Assembly has been published.
  class AssemblyActivityCell < ActivityCell
    def title
      I18n.t "decidim.assemblies.last_activity.new_assembly"
    end
  end
end
