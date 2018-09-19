# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.accountability.last_activity.new_result_at_html",
          link: link_to(
            translated_attribute(model.component.participatory_space.title),
            resource_locator(model.component.participatory_space).path
          )
        )
      end
    end
  end
end
