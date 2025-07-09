# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the vote count.
    # Two possible layouts:
    # - with the count label ("0 votes", "1 vote", "999 votes")
    # - without the count label ("0", "1", "999")
    class ProjectVotesCountCell < Decidim::ViewModel
      delegate :show_votes_count?, to: :controller

      def show
        return unless show_votes_count?

        content_tag :span, content, class: css_class
      end

      private

      def content
        if options[:layout] == :with_count_label
          safe_join([model.confirmed_orders_count, " ", count_label])
        else
          number
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
