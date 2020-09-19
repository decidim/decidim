# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders a checkmark with a text.
    class ProjectVotedHintCell < BaseCell
      include Decidim::IconHelper

      delegate :voted_for?, :current_order, to: :controller

      def show
        return unless voted_for?(model)

        content_tag :span, safe_join(hint), class: css_class
      end

      private

      def hint
        contents = []
        contents << icon("check", role: "img")
        contents << " "
        contents << t("decidim.budgets.projects.project.you_voted")
      end

      def css_class
        css = ["text-sm", "text-success"]
        css << options[:class] if options[:class]
        css.join(" ")
      end
    end
  end
end
