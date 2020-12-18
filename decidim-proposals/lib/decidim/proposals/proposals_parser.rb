# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalParser < Decidim::Admin::Import::Parser
      def self.resource_klass
        Decidim::Proposals::Proposal
      end

      def parse
        proposal = Decidim::Proposals::Proposal.new(
          category: category,
          scope: scope,
          title: title,
          body: body,
          component: component,
          published_at: Time.current
        )

        proposal.add_coauthor(user)
        proposal.save!

        increase_scores(proposal)
        notify(proposal)
        publish(proposal)

        proposal
      end

      private

      attr_reader :user, :user_group

      def category
        Decidim::Category.find(data[:"category/id"].to_i)
      end

      def scope
        Decidim::Scope.find(data[:"scope/id"].to_i)
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
        @component ||= Decidim::Component.find(data[:"component/id"].to_i)
      end

      def increase_scores(proposal)
        proposal.coauthorships.find_each do |coauthorship|
          if coauthorship.user_group
            Decidim::Gamification.increment_score(coauthorship.user_group, :proposals)
          else
            Decidim::Gamification.increment_score(coauthorship.author, :proposals)
          end
        end
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
