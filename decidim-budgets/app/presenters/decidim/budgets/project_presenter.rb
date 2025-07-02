# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectPresenter < Decidim::ResourcePresenter
      # Renders the title of the project
      #
      # @param html_escape [Boolean] Should HTML entities within the title be escaped? Default is +false+.
      # @param all_locales [Boolean] Should the title be returned for all locales? Default is +false+.
      # @return [String] The title of the project.
      def title(links: nil, extras: nil, html_escape: false, all_locales: false)
        return unless project

        raise "Extras has been set" unless extras.nil?
        raise "Links have been set" unless links.nil?

        super(project.title, html_escape, all_locales)
      end

      delegate_missing_to :project

      private

      def project
        __getobj__
      end
    end
  end
end
