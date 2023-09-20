# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposals picker.
    class ProposalsPickerCell < Decidim::ViewModel
      MAX_PROPOSALS = 1000

      def show
        render
      end

      alias component model

      def form
        options[:form]
      end

      def field
        options[:field]
      end

      def form_name
        "#{form.object_name}[#{method_name}]"
      end

      def method_name
        field.to_s.sub(/s$/, "_ids")
      end

      def selected_ids
        form.object.send(method_name)
      end

      def proposals
        @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, component)
                         &.includes(:component)
                         &.published
                         &.not_hidden
                         &.order(id: :asc)
      end

      def decorated_proposals
        proposals.limit(MAX_PROPOSALS).each do |proposal|
          yield Decidim::Proposals::ProposalPresenter.new(proposal)
        end
      end

      # deprecated
      def filtered?
        !search_text.nil?
      end

      # deprecated
      def picker_path
        request.path
      end

      # deprecated
      def search_text
        params[:q]
      end

      # deprecated
      def more_proposals?
        @more_proposals ||= more_proposals_count.positive?
      end

      # deprecated
      def more_proposals_count
        @more_proposals_count ||= proposals_count - MAX_PROPOSALS
      end

      # deprecated
      def proposals_count
        @proposals_count ||= filtered_proposals.count
      end

      # deprecated
      def filtered_proposals
        @filtered_proposals ||= if filtered?
                                  table_name = Decidim::Proposals::Proposal.table_name
                                  proposals.where(%("#{table_name}"."title"::text ILIKE ?), "%#{search_text}%")
                                           .or(proposals.where(%("#{table_name}"."reference" ILIKE ?), "%#{search_text}%"))
                                           .or(proposals.where(%("#{table_name}"."id"::text ILIKE ?), "%#{search_text}%"))
                                else
                                  proposals
                                end
      end

      # deprecated
      def proposals_collection_name
        Decidim::Proposals::Proposal.model_name.human(count: 2)
      end
    end
  end
end
