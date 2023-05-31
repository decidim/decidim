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
          participatory_space_id: voting.id,
          url:,
          title: voting.title,
          description: voting.description,
          start_time: voting.start_time.to_s(:db),
          end_time: voting.end_time.to_s(:db),
          voting_type: translated_voting_type,
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
      alias resource voting

      def translated_voting_type
        translation_hash = {}
        voting.organization.available_locales.each do |locale|
          translation_hash[locale] = I18n.t(voting.voting_type, scope: "decidim.votings.admin.votings.form.voting_type")
        end

        translation_hash
      end

      def url
        Decidim::Votings::Engine.routes.url_helpers.voting_url(host: voting.organization.host, slug: voting.slug)
      end
    end
  end
end
