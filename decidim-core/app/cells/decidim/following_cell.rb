# frozen_string_literal: true

module Decidim
  class FollowingCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      render :show
    end

    def followings
      @followings ||= Kaminari.paginate_array(model.following_users).page(params[:page]).per(20)
    end
  end
end
