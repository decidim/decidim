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

      def cache_hash
        @cache_hash ||= begin
          hash = []
          hash << I18n.locale.to_s
          hash << self.class.name.demodulize.underscore
          hash << model.cache_key_with_version
          hash << model.proposal_votes_count
          hash << model.endorsements_count
          hash << model.comments_count
          hash << Digest::MD5.hexdigest(model.component.cache_key_with_version)
          hash << Digest::MD5.hexdigest(resource_image_url) if resource_image_url
          hash << render_space? ? 1 : 0
          hash << model.follows_count
          hash << Digest::MD5.hexdigest(model.authors.map(&:cache_key_with_version).to_s)
          hash << (model.must_render_translation?(model.organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)
          hash << model.component.participatory_space.active_step.id if model.component.participatory_space.try(:active_step)

          hash.join(Decidim.cache_key_separator)
        end
      end
    end
  end
end
