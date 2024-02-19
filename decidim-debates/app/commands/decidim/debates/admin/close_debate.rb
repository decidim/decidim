# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # A command with all the business logic when an admin closes a debate.
      class CloseDebate < Decidim::Debates::CloseDebate
        private

        def attributes
          {
            conclusions: form.conclusions,
            closed_at: form.closed_at
          }
        end
      end
    end
  end
end
