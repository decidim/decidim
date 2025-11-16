# frozen_string_literal: true

module Decidim
  module Elections
    # Helpers to render the states as labels on Elections (ongoing, finished, unpublished)
    module LabelHelper
      def election_status_with_label(election)
        css_class = case election.status
                    when :ongoing
                      "warning"
                    when :finished
                      "success"
                    when :unpublished
                      "alert"
                    else
                      "reverse"
                    end

        content_tag(:span,
                    I18n.t("decidim.elections.status.#{election.status}"),
                    class: "#{css_class} label")
      end
    end
  end
end
