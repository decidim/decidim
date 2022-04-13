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

    def public_followings
      @public_followings ||= Kaminari.paginate_array(model.public_followings.find_all{|user| !user.blocked}).page(params[:page]).per(20)
    end

    def non_public_followings?
      public_followings.count < model.following_count
    end
  end
end
