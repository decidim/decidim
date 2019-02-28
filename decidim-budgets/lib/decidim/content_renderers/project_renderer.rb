# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing projects in content
    # and replaces it with a link to their show page.
    #
    # e.g. gid://<APP_NAME>/Decidim::Budgets::Project/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class ProjectRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX = %r{gid:\/\/([\w-]*\/Decidim::Budgets::Project\/(\d+))}i

      # Replaces found Global IDs matching an existing project with
      # a link to its show page. The Global IDs representing an
      # invalid Decidim::Projects::Project are replaced with '???' string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render
        content.gsub(GLOBAL_ID_REGEX) do |project_gid|
          begin
            project = GlobalID::Locator.locate(project_gid)
            Decidim::Budgets::ProjectPresenter.new(project).display_mention
          rescue ActiveRecord::RecordNotFound
            project_id = project_gid.split("/").last
            "~#{project_id}"
          end
        end
      end
    end
  end
end
