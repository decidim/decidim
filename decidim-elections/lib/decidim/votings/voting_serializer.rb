# frozen_string_literal: true

module Decidim
  module Votings
    # This class serializes a Voting so it can be exported to CSV, JSON or other
    # formats.
    class VotingSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a voting.
      def initialize(voting)
        @voting = voting
      end

      # Public: Exports a hash with the serialized data for this voting.
      def serialize
        {
          id: voting.id,
          url: url,
          title: voting.title,
          description: voting.description,
          start_time: voting.start_time.to_s(:db),
          end_time: voting.end_time.to_s(:db),
          voting_type: voting.voting_type,
          scope: {
            id: voting.scope.try(:id),
            name: voting.scope.try(:name)
          },
          banner_image_url: Decidim::Votings::VotingPresenter.new(voting).banner_image_url,
          introductory_image_url: Decidim::Votings::VotingPresenter.new(voting).introductory_image_url
        }
      end

      private

      attr_reader :voting

      def url
        Decidim::Votings::Engine.routes.url_helpers.voting_url(host: voting.organization.host, slug: voting.slug)
      end
    end
  end
end
