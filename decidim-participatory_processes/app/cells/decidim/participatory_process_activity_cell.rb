# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessActivityCell < ActivityCell
    def title
      I18n.t "decidim.participatory_processes.last_activity.new_participatory_process"
    end
  end
end
