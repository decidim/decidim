# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the partners card for an instance of a Partner
    class PartnerCell < Decidim::ViewModel
      def show
        render
      end

      private

      def partner
        return block unless model.link.presence
        link_to "#{logo} #{name}", model.link, class: css_class, target: "_blank"
      end

      def block
        "<div class='#{css_class}'> #{logo} #{name} </div>"
      end

      def name
        return unless model.name.presence
        "<div class='text-medium'> #{model.name} </div>"
      end

      def logo
        return unless model.logo.presence
        "<div class='card p-m flex--cc'> #{image_tag model.logo.medium.url} </div>"
      end

      def css_class
        "partner-box column collapse text-center mb-m"
      end
    end
  end
end
