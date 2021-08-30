# frozen_string_literal: true

module Decidim
  module Proposals
    # This class is responsible for creating the imported proposal answers
    # and must be included in proposals component's import manifest.
    class ProposalAnswerCreator < Decidim::Admin::Import::Creator
      def initialize(data, context = nil)
        @data = data
        @context = context
      end

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
        super
        notify(resource)
      end

      private

      attr_reader :context

      def resource
        @resource ||= begin
          p = Decidim::Proposals::Proposal.find(id)
          p.answer = answer
          p.state = state
          p.answered_at = Time.current
          p
        end
      end

      def id
        data[:id]
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

      def notify(proposal)
        ::Decidim::Proposals::Admin::NotifyProposalAnswer.call(proposal, nil)
      end
    end
  end
end
