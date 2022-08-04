# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the partners card for an instance of a Partner
    class PartnerCell < Decidim::ViewModel
      def show
        render
      end

      private

      # deprecated
      def name
        return unless model.name.presence

        "<div class='text-medium'> #{model.name} </div>"
      end

      # deprecated
      def logo
        return unless model.logo.attached?

        "<div class='card p-m flex--cc'> #{image_tag model.attached_uploader(:logo).path(variant: :medium), alt: "logo"} </div>"
      end
    end
  end
end
