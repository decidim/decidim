# frozen_string_literal: true

module Decidim
  module Proposals
    # This class is responsible for creating the imported proposals
    # and must be included in proposals component's import manifest.
    class ProposalCreator < Decidim::Admin::Import::Creator
      # Retuns the resource class to be created with the provided data.
      def self.resource_klass
        Decidim::Proposals::Proposal
      end

      # Produces a proposal from parsed data
      #
      # Returns a proposal
      def produce
        proposal.add_coauthor(context[:current_user], user_group: context[:user_group])

        proposal
      end

      # Saves the proposal
      def finish!
        super # proposal.save!
        notify(proposal)
        publish(proposal)
      end

      private

      attr_reader :context

      def proposal
        @proposal ||= Decidim::Proposals::Proposal.new(
          category: category,
          scope: scope,
          title: title,
          body: body,
          component: component,
          published_at: Time.current
        )
      end

      def category
        id = data.has_key?(:category) ? data[:category]["id"] : data[:"category/id"].to_i
        Decidim::Category.find_by(id: id)
      end

      def scope
        id = data.has_key?(:scope) ? data[:scope]["id"] : data[:"scope/id"].to_i
        Decidim::Scope.find_by(id: id)
      end

      def title
        locale_hasher("title", available_locales)
      end

      def body
        locale_hasher("body", available_locales)
      end

      def available_locales
        @available_locales ||= component.participatory_space.organization.available_locales
      end

      def component
        context[:current_component]
      end

      def notify(proposal)
        return if proposal.coauthorships.empty?

        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: proposal,
          followers: coauthors_followers(proposal)
        )
      end

      def publish(proposal)
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: proposal,
          followers: proposal.participatory_space.followers - coauthors_followers(proposal),
          extra: {
            participatory_space: true
          }
        )
      end

      def coauthors_followers(proposal)
        @coauthors_followers ||= proposal.authors.flat_map(&:followers)
      end
    end
  end
end
