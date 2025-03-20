# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the proposal card for an instance of a Proposal
    # the default size is the Grid Card (:g)
    class ProposalGCell < Decidim::CardGCell
      include Decidim::Proposals::ApplicationHelper
      include Decidim::LayoutHelper

      delegate :state_item, to: :metadata_cell_instance

      def show
        render
      end

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/proposals/proposal_metadata"
      end

      def metadata_cell_instance
        @metadata_cell_instance ||= cell("decidim/proposals/proposal_metadata", model)
      end

      def resource_image_path
        model.attachments.first&.url
      end

      private

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
          hash << 0 # render space
          hash << model.follows_count
          hash << Digest::MD5.hexdigest(model.authors.map(&:cache_key_with_version).to_s)
          hash << (model.must_render_translation?(model.organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)
          hash << model.component.participatory_space.active_step.id if model.component.participatory_space.try(:active_step)

          hash.join(Decidim.cache_key_separator)
        end
      end

      def classes
        super.merge(metadata: "card__list-metadata")
      end
    end
  end
end
