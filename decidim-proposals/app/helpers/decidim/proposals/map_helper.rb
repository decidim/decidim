# frozen_string_literal: true

module Decidim
  module Proposals
    # This helper include some methods for rendering proposals dynamic maps.
    module MapHelper
      # Serialize a collection of geocoded proposals to be used by the dynamic map component
      #
      # geocoded_proposals - A collection of geocoded proposals
      def proposals_data_for_map(geocoded_proposals)
        geocoded_proposals.map do |proposal|
          proposal.slice(:latitude, :longitude, :address).merge(title: proposal.title,
                                                                body: truncate(proposal.body, length: 100),
                                                                icon: icon("proposals", width: 40, height: 70, remove_icon_class: true),
                                                                link: proposal_path(proposal))
        end
      end
    end
  end
end
