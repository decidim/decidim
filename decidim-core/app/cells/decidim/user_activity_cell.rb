# frozen_string_literal: true

module Decidim
  class UserActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include CellsPaginateHelper
    include Decidim::LayoutHelper
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::FormOptionsHelper
    include Decidim::FiltersHelper

    def show
      render :show
    end

    def activities
      context[:activities]
    end

    def resource_types
      context[:resource_types]
    end
  end
end
