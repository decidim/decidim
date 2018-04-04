# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing categories for questions.
      #
      class CategoriesController < Decidim::Admin::CategoriesController
        include QuestionAdmin
      end
    end
  end
end
