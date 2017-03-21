# frozen_string_literal: true
module Decidim
  module Admin
    module IconLinkHelper
      def icon_link_to(icon_name, link, title, klass, data={})
        link_to(link,
                class: "action-icon " + klass,
                data: { tooltip: true, disable_hover: false }.merge(data),
                tooltip: true,
                disable_hover: false,
                title: title) do
          icon(icon_name)
        end
      end
    end
  end
end
