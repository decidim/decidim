# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing categories for conferences.
      #
      class CategoriesController < Decidim::Admin::CategoriesController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
