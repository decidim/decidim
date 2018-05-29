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
      @followings ||= Kaminari.paginate_array(following_users).page(params[:page]).per(20)
    end

    def following_users
      @following_users ||= model.following.select do |following|
        following.is_a?(Decidim::User)
      end
    end
  end
end
