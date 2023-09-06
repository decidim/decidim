# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command gets called when a voting is unpublished from the admin panel.
      class UnpublishVoting < Decidim::Admin::ParticipatorySpace::Unpublish
        private

        def default_options = { visibility: "all" }
      end
    end
  end
end
