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
          taxonomies:,
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
          state_published_at: proposal.state_published_at,
          reference: proposal.reference,
          answer: ensure_translatable(proposal.answer),
          answered_at: proposal.answered_at,
          votes: (proposal.proposal_votes_count unless
          proposal.component.current_settings.votes_hidden?),
          likes: {
            total_count: proposal.likes.size,
            user_endorsements:
          },
          comments: proposal.comments_count,
          attachments: proposal.attachments.size,
          follows_count: proposal.follows_count,
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
          withdrawn_at: proposal.withdrawn_at,
          created_at: proposal.created_at,
          updated_at: proposal.updated_at,
          created_in_meeting: proposal.created_in_meeting,
          coauthorships_count: proposal.coauthorships_count,
          cost: proposal.cost,
          cost_report: proposal.cost_report,
          execution_period: proposal.execution_period
        }
      end

      private

      attr_reader :proposal
      alias resource proposal

      def meetings
        proposal.linked_resources(:meetings, "proposals_from_meeting").map do |meeting|
          Decidim::ResourceLocatorPresenter.new(meeting).url
        end
      end

      def related_proposals
        proposal.linked_resources(:proposals, %w(copied_from_component merged_from_component splitted_from_component)).map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(proposal).url
      end

      def user_endorsements
        proposal.likes.for_listing.map { |identity| identity.author&.name }
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
        {
          id: resource.authors.map(&:id),
          name: resource.authors.map do |author|
            author_name(author)
          end,
          url: resource.authors.map do |author|
            author_url(author)
          end
        }
      end

      def author_name(author)
        if author.respond_to?(:name)
          translated_attribute(author.name) # is a Decidim::User or Decidim::Organization
        elsif author.respond_to?(:title)
          translated_attribute(author.title) # is a Decidim::Meetings::Meeting
        end
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author) # is a Decidim::User
        elsif author.respond_to?(:title)
          meeting_url(author) # is a Decidim::Meetings::Meeting
        else
          root_url # is a Decidim::Organization
        end
      end

      def meeting_url(meeting)
        Decidim::EngineRouter.main_proxy(meeting.component).meeting_url(id: meeting.id, host:)
      end
    end
  end
end
