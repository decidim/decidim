# frozen_string_literal: true

module Decidim
  class UserActivityCell < Decidim::ViewModel
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers

    delegate :params, to: :controller

    def show
      render :show
    end

    def activities
      context[:activities]
    end
  end
end
