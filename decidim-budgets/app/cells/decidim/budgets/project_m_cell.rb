# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the Medium (:m) project card
    # for an given instance of a Project
    class ProjectMCell < Decidim::CardMCell
      include ActiveSupport::NumberHelper
      include Decidim::Budgets::ProjectsHelper

      private

      def resource_icon
        icon "projects", class: "icon--big"
      end

      def resource_path
        resource_locator([model.budget, model]).path
      end
    end
  end
end
