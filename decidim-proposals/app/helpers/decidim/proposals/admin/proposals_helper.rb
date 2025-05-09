# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This class contains helpers needed to format Meetings
      # in order to use them in select forms for Proposals.
      #
      module ProposalsHelper
        include Decidim::TranslatableAttributes

        def available_states
          [
            Decidim::Proposals::ProposalState.where(component: current_component).new(
              token: "not_answered",
              title: t("decidim.proposals.answers.not_answered")
            )
          ] + Decidim::Proposals::ProposalState.where(component: current_component).all
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

        def endorsers_presenters_for(proposal)
          proposal.likes.for_listing.map { |identity| present(identity.author) }
        end

        def proposal_complete_state(proposal)
          return humanize_proposal_state(:withdrawn).html_safe if proposal.withdrawn?
          return humanize_proposal_state("not_answered").html_safe if proposal.proposal_state.nil?

          translated_attribute(proposal&.proposal_state&.title)
        end

        def icon_with_link_to_proposal(proposal)
          icon, tooltip = if allowed_to?(:create, :proposal_answer, proposal:) && !proposal.emendation?
                            [
                              "question-answer-line",
                              t(:answer_proposal, scope: "decidim.proposals.actions")
                            ]
                          else
                            [
                              "information-line",
                              t(:show, scope: "decidim.proposals.actions")
                            ]
                          end
          icon_link_to(icon, proposal_path(proposal), tooltip, class: "icon--small action-icon--show-proposal")
        end
      end
    end
  end
end
