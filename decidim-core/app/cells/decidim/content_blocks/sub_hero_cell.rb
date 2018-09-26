# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class SubHeroCell < Decidim::ViewModel
      include Decidim::IconHelper
      include Decidim::SanitizeHelper

      def show
        return if translated_attribute(current_organization.description).blank?
        render
      end

      delegate :current_organization, to: :controller
    end
  end
end
