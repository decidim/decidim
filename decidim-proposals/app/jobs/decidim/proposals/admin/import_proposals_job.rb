# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ImportProposalsJob < ApplicationJob
        queue_as :default

        def perform(form)
          @form = form
          ActiveRecord::Base.transaction do
            proposals.map do |original_proposal|
              next if proposal_already_copied?(original_proposal, target_component)

              Decidim::Proposals::ProposalBuilder.copy(
                original_proposal,
                author: proposal_author,
                action_user: current_user,
                extra_attributes: {
                  "component" => target_component
                }.merge(proposal_answer_attributes(original_proposal))
              )
            end
          end
          ImportProposalsMailer.notify_success(current_user, origin_component, target_component, proposals.count).deliver_later
        rescue ActiveRecord::RecordNotFound, NoMethodError
          ImportProposalsMailer.notify_failure(current_user, origin_component, target_component).deliver_later
        end

        private

        def proposals
          proposals = Decidim::Proposals::Proposal.not_hidden.not_withdrawn.where(component: origin_component)
          proposals = proposals.where(scope: proposal_scopes) unless proposal_scopes.empty?

          if @form["states"].include?("not_answered")
            proposals.not_answered.or(proposals.where(id: proposals.only_status(@form["states"]).pluck(:id)))
          else
            proposals.only_status(@form["states"])
          end
        end

        def origin_component
          @origin_component ||= Decidim::Component.find(@form["origin_component_id"])
        end

        def target_component
          @target_component ||= Decidim::Component.find(@form["current_component_id"])
        end

        def current_user
          @current_user ||= Decidim::User.find(@form["current_user_id"])
        end

        def current_organization
          @current_organization ||= Decidim::Organization.find(@form["current_organization_id"])
        end

        def proposal_already_copied?(original_proposal, target_component)
          # Note: we are including also proposals from unpublished components
          # because otherwise duplicates could be created until the component is
          # published.
          original_proposal.linked_resources(:proposals, "copied_from_component", component_published: false).any? do |proposal|
            proposal.component == target_component
          end
        end

        def proposal_author
          @form["keep_authors"] ? nil : current_organization
        end

        def proposal_scopes
          @form["scopes"] || []
        end

        def proposal_answer_attributes(original_proposal)
          return {} unless @form["keep_answers"]

          state = Decidim::Proposals::ProposalState.where(component: target_component, token: original_proposal.proposal_state&.token).first

          {
            answer: original_proposal.answer,
            answered_at: original_proposal.answered_at,
            proposal_state: state,
            state_published_at: original_proposal.state_published_at
          }
        end
      end
    end
  end
end
