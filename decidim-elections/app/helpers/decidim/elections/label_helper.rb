# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers, scoped to the elections engine.
    #
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
