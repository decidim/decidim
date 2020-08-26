# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the partners card for an instance of a Partner
    class PartnerCell < Decidim::ViewModel
      def show
        render
      end

      private

      def name
        return unless model.name.presence

        "<div class='text-medium'> #{model.name} </div>"
      end

      def logo
        return unless model.logo.presence

        "<div class='card p-m flex--cc'> #{image_tag model.logo.medium.url, alt: "logo"} </div>"
      end
    end
  end
end
