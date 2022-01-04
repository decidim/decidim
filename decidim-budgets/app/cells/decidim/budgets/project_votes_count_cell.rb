# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the vote count.
    # Two possible layouts: One or two lines
    class ProjectVotesCountCell < Decidim::ViewModel
      include Decidim::IconHelper
      delegate :show_votes_count?, to: :controller

      def show
        return unless show_votes_count?

        content_tag :span, content, class: css_class
      end

      private

      def content
        if options[:layout] == :one_line
          safe_join([model.total_votes, " ", label(t("decidim.budgets.projects.project.votes",
                                                                count: model.total_votes))])
        else
          safe_join([number, label(t("decidim.budgets.projects.project.votes",
                                     count: model.total_votes))])
        end
      end

      def number
        content_tag :div, model.total_votes, class: "text-large"
      end

      def label(i18n_string)
        content_tag :span, i18n_string, class: "text-uppercase text-small"
      end

      def css_class
        css = ["project-votes"]
        css << options[:class] if options[:class]
        css.join(" ")
      end
    end
  end
end
