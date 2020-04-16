# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      class BaseCell < Decidim::ViewModel
        include Decidim::LayoutHelper
        include Decidim::SanitizeHelper
        include Decidim::ComponentPathHelper
        include Decidim::Budgets::Engine.routes.url_helpers

        delegate :current_user, to: :controller
      end
    end
  end
end
