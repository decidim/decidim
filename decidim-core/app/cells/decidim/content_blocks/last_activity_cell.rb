# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class LastActivityCell < Decidim::ViewModel
      include Decidim::Core::Engine.routes.url_helpers

      delegate :current_organization, to: :controller

      def show
        return if activities.empty?
        render
      end

      def activities
        @activities ||= ActivitySearch.new(
          organization: current_organization,
          resource_type: "all"
        ).results.limit(8)
      end
    end
  end
end
