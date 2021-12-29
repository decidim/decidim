# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders the image of the physical certificate of a Polling Station Closure
    class PollingStationClosureCertificateCell < Decidim::ViewModel
      def has_images?
        model.photos.present?
      end
    end
  end
end
