# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Custom helpers for election steps on admin dashboard.
      #
      module StepsHelper
        def steps(current_step)
          step_class = "text-success"
          (["create_election"] + Decidim::Elections::Election.bb_statuses.keys).map do |step|
            if step == current_step
              step_class = "text-muted"
              [step, "text-warning"]
            else
              [step, step_class]
            end
          end
        end
      end
    end
  end
end
