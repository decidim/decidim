# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders the Grid (:g) voting card
    # for a given instance of a Voting
    class VotingGCell < Decidim::CardGCell
      private

      def resource_image_path
        model.attached_uploader(:banner_image).path
      end

      def metadata_cell
        "decidim/votings/voting_metadata"
      end
    end
  end
end
