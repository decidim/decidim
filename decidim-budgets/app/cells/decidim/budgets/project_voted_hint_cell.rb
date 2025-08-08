# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders a checkmark with a text.
    class ProjectVotedHintCell < BaseCell
      delegate :voted_for?, :current_order, to: :controller

      def show
        return unless voted_for?(model)

        content_tag :span, hint, class: css_class
      end

      private

      def hint
        content_tag :div, class: "success" do
          contents = []
          contents << icon("check-line", role: "img", "aria-hidden": true)
          contents << " "
          contents << t("decidim.budgets.projects.project.you_voted")
          safe_join(contents)
        end
      end

      def css_class
        css = ["card__list-metadata"]
        css << options[:class] if options[:class]
        css.join(" ")
      end
    end
  end
end
