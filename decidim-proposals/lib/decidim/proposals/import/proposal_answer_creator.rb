# frozen_string_literal: true

module Decidim
  module Proposals
    module Import
      # This class is responsible for creating the imported proposal answers
      # and must be included in proposals component's import manifest.
      class ProposalAnswerCreator < Decidim::Admin::Import::Creator
        # Returns the resource class to be created with the provided data.
        def self.resource_klass
          Decidim::Proposals::Proposal
        end

        # Returns a verifier class to be used to verify the correctness of the
        # import data.
        def self.verifier_klass
          Decidim::Proposals::Import::ProposalsAnswersVerifier
        end

        # Add answer to proposal
        #
        # Returns a proposal
        def produce
          resource
        end

        def finish!
          Decidim.traceability.perform_action!(
            "answer",
            resource,
            current_user
          ) do
            resource.try(:save!)
          end

          notify
        end

        private

        attr_reader :initial_status

        def resource
          @resource ||= fetch_resource
        end

        def fetch_resource
          proposal = Decidim::Proposals::Proposal.find_by(id:)
          return nil unless proposal
          return nil if proposal.emendation?

          if proposal.component != component
            proposal.errors.add(:component, :invalid)
            return proposal
          end

          proposal.answer = answer
          proposal.answered_at = Time.current
          @initial_status = proposal.proposal_status

          proposal_status = Decidim::Proposals::ProposalStatus.where(component:, token: status).first

          if proposal_status.present?
            proposal.proposal_status = proposal_status
            proposal.status_published_at = Time.current if component.current_settings.publish_answers_immediately?
          else
            proposal.errors.add(:status, :invalid)
          end
          proposal
        end

        def id
          data[:id].to_i
        end

        def status
          data[:status]
        end

        def answer
          locale_hasher("answer", available_locales)
        end

        def available_locales
          @available_locales ||= component.participatory_space.organization.available_locales
        end

        def component
          context[:current_component]
        end

        def current_user
          context[:current_user]
        end

        def notify
          status = initial_status || resource.try(:status)
          ::Decidim::Proposals::Admin::NotifyProposalAnswer.call(resource, status)
        end
      end
    end
  end
end
