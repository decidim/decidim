# frozen_string_literal: true

module Decidim
  module Proposals
    module Log
      class EvaluationAssignmentPresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          if resource.present?
            resource.proposal.presenter.title(html_escape: true)
          else
            super
          end
        end
      end
    end
  end
end
