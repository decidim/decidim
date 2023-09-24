# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Budgets
    # This cell renders the Search (:s) project card
    # for an instance of a Project
    class ProjectSCell < Decidim::CardSCell
      private

      def resource_path
        resource_locator([model.budget, model]).path
      end

      def metadata_cell
        "decidim/budgets/project_metadata"
      end
    end
  end
end
