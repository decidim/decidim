# frozen_string_literal: true

module Decidim
  # Helper that provides a single method to create filter resource forms
  module FiltersHelper
    # This method wraps everything in a div with class filters and calls
    # the form_for helper with a custom builder
    #
    # filter - A filter object
    # block  - A block to be called with the form builder
    #
    # Returns the filter resource form wrapped in a div
    def filter_form_for(filter)
      content_tag :div, class: "filters" do
        form_for filter, builder: FilterFormBuilder, url: url_for, as: :filter, method: :get, remote: true, html: { id: nil } do |form|
          yield form
        end
      end
    end
  end
end
