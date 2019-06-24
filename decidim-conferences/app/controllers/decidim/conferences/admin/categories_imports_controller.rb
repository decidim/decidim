# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows importing categories for conferences.
      #
      class CategoriesImportsController < Decidim::Admin::CategoriesImportsController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
