# frozen_string_literal: true

module Decidim
  module Proposals
    module Log
      class ResourcePresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          if resource.present?
            Decidim::Proposals::ProposalPresenter.new(resource).title
          else
            super
          end
        end
      end
    end
  end
end
