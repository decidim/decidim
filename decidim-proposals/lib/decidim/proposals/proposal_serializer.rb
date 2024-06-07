# frozen_string_literal: true

module Decidim
  module Proposals
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class ProposalSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include HtmlToPlainText

      # Public: Initializes the serializer with a proposal.
      def initialize(proposal)
        @proposal = proposal
      end

      # Public: Exports a hash with the serialized data for this proposal.
      def serialize
        {
          id: proposal.id,
          author: {
            **author_fields
          },
          category: {
            id: proposal.category.try(:id),
            name: proposal.category.try(:name) || empty_translatable
          },
          scope: {
            id: proposal.scope.try(:id),
            name: proposal.scope.try(:name) || empty_translatable
          },
          participatory_space: {
            id: proposal.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
          },
          component: { id: component.id },
          title: proposal.title,
          body: convert_to_plain_text(proposal.body),
          address: proposal.address,
          latitude: proposal.latitude,
          longitude: proposal.longitude,
          state: proposal.state.to_s,
          reference: proposal.reference,
          answer: ensure_translatable(proposal.answer),
          answered_at: proposal.answered_at,
          votes: proposal.proposal_votes_count,
          endorsements: {
            total_count: proposal.endorsements.size,
            user_endorsements:
          },
          comments: proposal.comments_count,
          attachments: proposal.attachments.size,
          followers: proposal.follows.size,
          published_at: proposal.published_at,
          url:,
          meeting_urls: meetings,
          related_proposals:,
          is_amend: proposal.emendation?,
          original_proposal: {
            title: proposal&.amendable&.title,
            url: original_proposal_url
          },
          withdrawn: proposal.withdrawn?,
          withdrawn_at: proposal.withdrawn_at
        }
      end

      private

      attr_reader :proposal
      alias resource proposal

      def component
        proposal.component
      end

      def meetings
        proposal.linked_resources(:meetings, "proposals_from_meeting").map do |meeting|
          Decidim::ResourceLocatorPresenter.new(meeting).url
        end
      end

      def related_proposals
        proposal.linked_resources(:proposals, "copied_from_component").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(proposal).url
      end

      def user_endorsements
        proposal.endorsements.for_listing.map { |identity| identity.normalized_author&.name }
      end

      def original_proposal_url
        return unless proposal.emendation? && proposal.amendable.present?

        Decidim::ResourceLocatorPresenter.new(proposal.amendable).url
      end

      # Recursively strips HTML tags from given Hash strings using convert_to_text from Premailer
      def convert_to_plain_text(value)
        return value.transform_values { |v| convert_to_plain_text(v) } if value.is_a?(Hash)

        convert_to_text(value)
      end

      def author_fields
        is_author_user_group = resource.coauthorships.map(&:decidim_user_group_id).any?

        {
          id: resource.authors.map(&:id),
          name: resource.authors.map do |author|
            author_name(is_author_user_group ? resource.coauthorships.first.user_group : author)
          end,
          url: resource.authors.map do |author|
            author_url(is_author_user_group ? resource.coauthorships.first.user_group : author)
          end
        }
      end

      def author_name(author)
        if author.respond_to?(:name)
          translated_attribute(author.name) # is a Decidim::User or Decidim::Organization or Decidim::UserGroup
        elsif author.respond_to?(:title)
          translated_attribute(author.title) # is a Decidim::Meetings::Meeting
        end
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author.nickname) # is a Decidim::User or Decidim::UserGroup
        elsif author.respond_to?(:title)
          meeting_url(author) # is a Decidim::Meetings::Meeting
        else
          root_url # is a Decidim::Organization
        end
      end

      def profile_url(nickname)
        Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:)
      end

      def meeting_url(meeting)
        Decidim::EngineRouter.main_proxy(meeting.component).meeting_url(id: meeting.id, host:)
      end

      def root_url
        Decidim::Core::Engine.routes.url_helpers.root_url(host:)
      end

      def host
        resource.organization.host
      end
    end
  end
end
