# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectPresenter < Decidim::ResourcePresenter
      # Render the proposal title
      #
      # links - should render hashtags as links?
      # extras - should include extra hashtags?
      #
      # Returns a String.
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
