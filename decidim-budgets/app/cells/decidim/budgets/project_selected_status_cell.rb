# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the selected status if the project has been selected
    class ProjectSelectedStatusCell < Decidim::ViewModel
      delegate :voting_finished?, to: :controller

      def show
        if voting_finished? && model.selected?
          content_tag :span, class: "label success" do
            t("decidim.budgets.projects.project.selected")
          end
        end
      end
    end
  end
end
