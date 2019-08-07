# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing the Question's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ComponentsController
        include QuestionAdmin
      end
    end
  end
end
