# frozen_string_literal: true

module Decidim
  module Proposals
    # This class is responsible for creating the imported proposal answers
    # and must be included in proposals component's import manifest.
    class ProposalAnswerCreator < Decidim::Admin::Import::Creator
      POSSIBLE_ANSWER_STATES = %w(evaluating accepted rejected).freeze

      # Retuns the resource class to be created with the provided data.
      def self.resource_klass
        Decidim::Proposals::Proposal
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
          resource.save!
        end
        notify(resource)
      end

      # Check if prepared resource is valid
      #
      # record - Decidim::Proposals::Proposal
      #
      # Returns true if record is valid
      def self.resource_valid?(record)
        return false if record.nil?
        return false if record.errors.record.positive?

        record.valid?
      end

      def self.notification_resource
        I18n.t("decidim.admin.imports.resources.proposal_answers")
      end

      private

      attr_reader :context

      def resource
        @resource ||= begin
          return nil if Decidim::Proposals::Proposal.where(id: id).empty?

          proposal = Decidim::Proposals::Proposal.find(id)

          if proposal.component != component
            proposal.errors.add(:component, :invalid)
            return proposal
          end

          proposal.answer = answer
          proposal.answered_at = Time.current
          if POSSIBLE_ANSWER_STATES.include?(state)
            proposal.state = state
            proposal.state_published_at = Time.current if component.current_settings.publish_answers_immediately?
          else
            proposal.errors.add(:state, :invalid)
          end
          proposal
        end
      end

      def id
        data[:id].to_i
      end

      def state
        data[:state]
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

      def notify(proposal)
        ::Decidim::Proposals::Admin::NotifyProposalAnswer.call(proposal, proposal.state)
      end
    end
  end
end
