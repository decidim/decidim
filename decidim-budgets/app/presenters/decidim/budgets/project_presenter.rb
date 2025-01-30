# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectPresenter < Decidim::ResourcePresenter
      # Renders the title of the project
      #
      # @param links [Boolean] Should hashtags in the title be rendered as links? Default is +false+.
      # @param extras [Boolean] Should extra hashtags be included? Default is +true+.
      # @param html_escape [Boolean] Should HTML entities within the title be escaped? Default is +false+.
      # @param all_locales [Boolean] Should the title be returned for all locales? Default is +false+.
      # @return [String] The title of the project.
      def title(links: false, extras: true, html_escape: false, all_locales: false)
        return unless project

        super(project.title, links, html_escape, all_locales, extras:)
      end

      delegate_missing_to :project

      private

      def project
        __getobj__
      end
    end
  end
end
