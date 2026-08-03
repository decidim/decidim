# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to format Meetings
      # in order to use them in select forms for Proposals.
      #
      module ProposalsHelper
        include Decidim::TranslatableAttributes

        def available_statuses
          [
            Decidim::Proposals::ProposalStatus.where(component: current_component).new(
              token: "not_answered",
              title: t("decidim.proposals.answers.not_answered")
            )
          ] + Decidim::Proposals::ProposalStatus.where(component: current_component).all
        end

        # Public: A formatted collection of Meetings to be used
        # in forms.
        def meetings_as_authors_selected
          return unless @proposal.present? && @proposal.official_meeting?

          @meetings_as_authors_selected ||= @proposal.authors.pluck(:id)
        end

        def coauthor_presenters_for(proposal)
          proposal.authors.map do |identity|
            if identity.is_a?(Decidim::Organization)
              Decidim::Proposals::OfficialAuthorPresenter.new
            else
              present(identity)
            end
          end
        end

        def likes_presenters_for(proposal)
          proposal.likes.for_listing.map { |identity| present(identity.author) }
        end

        def proposal_complete_status(proposal)
          return humanize_proposal_status(:withdrawn).html_safe if proposal.withdrawn?
          return humanize_proposal_status("not_answered").html_safe if proposal.proposal_status.nil?

          translated_attribute(proposal&.proposal_status&.title)
        end
      end
    end
  end
end
