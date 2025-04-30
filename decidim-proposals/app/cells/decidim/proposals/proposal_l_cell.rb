# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the List (:l) proposal card
    # for an instance of a Proposal
    class ProposalLCell < Decidim::CardLCell
      alias proposal model

      def title
        present(proposal).title(html_escape: true)
      end

      private

      def metadata_cell
        "decidim/proposals/proposal_metadata"
      end

      def has_actions?
        model.component.current_settings.votes_enabled? && !model.draft? && !model.withdrawn? && !model.rejected?
      end

      def proposal_vote_cell
        "decidim/proposals/proposal_vote"
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def cache_hash
        @cache_hash ||= begin
          hash = []
          hash << I18n.locale.to_s
          hash << self.class.name.demodulize.underscore
          hash << model.cache_key_with_version
          hash << model.proposal_votes_count
          hash << options[:show_voting] ? 0 : 1
          hash << model.endorsements_count
          hash << model.comments_count
          hash << Digest::SHA256.hexdigest(model.component.cache_key_with_version)
          hash << Digest::SHA256.hexdigest(resource_image_url) if resource_image_url
          hash << render_space? ? 1 : 0
          hash << model.follows_count
          hash << Digest::SHA256.hexdigest(model.authors.map(&:cache_key_with_version).to_s)
          hash << (model.must_render_translation?(model.organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)
          hash << model.component.participatory_space.active_step.id if model.component.participatory_space.try(:active_step)
          hash << (current_user&.id || 0)

          hash.join(Decidim.cache_key_separator)
        end
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
