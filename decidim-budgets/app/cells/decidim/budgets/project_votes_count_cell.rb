# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the vote count.
    # Two possible layouts: One or two lines
    class ProjectVotesCountCell < Decidim::ViewModel
      include Decidim::IconHelper

      def show
        return unless show_votes_count?

        content_tag :span, content, class: css_class
      end

      private

      def show_votes_count?
        model.component.current_settings.show_votes?
      end

      def content
        if options[:layout] == :one_line
          safe_join([model.confirmed_orders_count, " ", count_label])
        else
          safe_join([number, count_label])
        end
      end

      def number
        content_tag :div, model.confirmed_orders_count
      end

      def count_label
        content_tag(:span, t("decidim.budgets.projects.project.votes", count: model.confirmed_orders_count))
      end

      def css_class
        css = ["project-votes"]
        css << options[:class] if options[:class]
        css.join(" ")
      end
    end
  end
end
