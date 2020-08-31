# frozen_string_literal: true

module Decidim
  class UserTimelineCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers

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
