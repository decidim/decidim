# frozen_string_literal: true

module Decidim
  module Proposals
    # This class is responsible for creating the imported proposal answers
    # and must be included in proposals component's import manifest.
    class ProposalAnswerCreator < Decidim::Admin::Import::Creator
      POSSIBLE_ANSWER_STATES = %w(evaluating accepted rejected).freeze

      class << self
        # Retuns the resource class to be created with the provided data.
        def resource_klass
          Decidim::Proposals::Proposal
        end

        # Check if prepared resource is valid
        #
        # record - Decidim::Proposals::Proposal
        #
        # Returns true if record is valid
        def resource_valid?(record)
          return false if record.nil?
          return false if record.errors.any?

          record.valid?
        end

        def required_static_headers
          %w(id state).map(&:to_sym).freeze
        end

        def required_dynamic_headers
          %w(answer).freeze
        end
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

      private

      def resource
        @resource ||= begin
          proposal = Decidim::Proposals::Proposal.find_by(id: id)
          return nil unless proposal
          return nil if proposal.emendation?

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
