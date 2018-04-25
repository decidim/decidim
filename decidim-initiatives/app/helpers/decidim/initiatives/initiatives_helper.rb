# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper functions for initiatives views
    module InitiativesHelper
      def initiatives_filter_form_for(filter)
        content_tag :div, class: "filters" do
          form_for filter,
                   builder: Decidim::Initiatives::InitiativesFilterFormBuilder,
                   url: url_for,
                   as: :filter,
                   method: :get,
                   remote: true,
                   html: { id: nil } do |form|
            yield form
          end
        end
      end
    end
  end
end
