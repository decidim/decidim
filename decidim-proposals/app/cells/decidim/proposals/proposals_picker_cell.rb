# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposals picker.
    class ProposalsPickerCell < Decidim::ViewModel
      MAX_PROPOSALS = 1000

      def show
        if filtered?
          render :proposals
        else
          render
        end
      end

      alias component model

      def filtered?
        !search_text.nil?
      end

      def picker_path
        request.path
      end

      def search_text
        params[:q]
      end

      def more_proposals?
        @more_proposals ||= more_proposals_count.positive?
      end

      def more_proposals_count
        @more_proposals_count ||= proposals_count - MAX_PROPOSALS
      end

      def proposals_count
        @proposals_count ||= filtered_proposals.count
      end

      def decorated_proposals
        filtered_proposals.limit(MAX_PROPOSALS).each do |proposal|
          yield Decidim::Proposals::ProposalPresenter.new(proposal)
        end
      end

      def filtered_proposals
        @filtered_proposals ||= if filtered?
                                  proposals.where("title::text ILIKE ?", "%#{search_text}%")
                                           .or(proposals.where("reference ILIKE ?", "%#{search_text}%"))
                                           .or(proposals.where("id::text ILIKE ?", "%#{search_text}%"))
                                else
                                  proposals
                                end
      end

      def proposals
        @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, component)
                       &.published
                       &.order(id: :asc)
      end

      def proposals_collection_name
        Decidim::Proposals::Proposal.model_name.human(count: 2)
      end
    end
  end
end
