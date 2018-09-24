# frozen_string_literal: true

module Decidim
  class AssemblyActivityCell < ActivityCell
    def title
      I18n.t "decidim.assemblies.last_activity.new_assembly"
    end
  end
end
