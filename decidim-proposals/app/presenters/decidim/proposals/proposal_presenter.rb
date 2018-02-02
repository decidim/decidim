# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    elsif user_group
                      Decidim::UserGroupPresenter.new(user_group)
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end

      def proposal_path
        proposal = __getobj__
        slug = proposal.participatory_space.slug
        decidim_participatory_process_proposals.proposal_path(__getobj__, feature_id: proposal.feature.id, participatory_process_slug: slug)
      end

      def display_mention
        link_to title, proposal_path # , class: "user-mention"
      end
    end
  end
end
