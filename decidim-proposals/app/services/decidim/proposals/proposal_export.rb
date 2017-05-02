# frozen_string_literal: true

require 'csv'

module Decidim
  module Proposals
    class ProposalExporter
      include Decidim::ResourceHelper

      def initialize(participatory_process)
        @proposals = participatory_process.proposals
      end

      def export
        CSV.generate do |csv|
          csv << generate_headers_from(@proposals.first)
          @proposals.each do |proposal|
            csv << row(proposal)
          end
        end
      end

      private

      def row(proposal)
        [
          proposal.try(:category).try(:name).try(:values), #get subcategories via .parent
          proposal.title,
          proposal.body,
          proposal.id, # TODO: use path
          proposal.proposal_votes_count,
          proposal.comments.count,
          proposal.linked_resources(:meetings, "proposals_from_meeting").pluck(:id)
        ].flatten
      end

      def generate_headers_from(proposal)
        [
          (proposal.try(:category).try(:name).try(:keys) || []).map{|l| "category_#{l}"},
          "title",
          "body",
          "proposal_path",
          "proposal_votes_count",
          "proposal_comments_count",
          "meeting_ids_where_discussed"
        ].flatten
      end
    end
  end
end
