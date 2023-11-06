# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the Grid (:g) election card
    # for a given instance of an Election
    class ElectionGCell < Decidim::CardGCell
      include ElectionCellsHelper

      def metadata_cell
        "decidim/elections/election_metadata"
      end

      def has_image?
        model.photos.present?
      end

      def resource_image_path
        model.photos.first.url if has_image?
      end
    end
  end
end
