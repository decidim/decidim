# frozen_string_literal: true

module Decidim
  # A cell to display when a Participatory Process has been published.
  class ParticipatoryProcessActivityCell < ActivityCell
    def title
      I18n.t "decidim.participatory_processes.last_activity.new_participatory_process"
    end
  end
end
