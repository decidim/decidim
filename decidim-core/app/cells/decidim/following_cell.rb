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
      @public_followings ||= Kaminari.paginate_array(model.public_users_followings).page(params[:page]).per(20)
    end

    def non_public_followings?
      model.followings_blocked?
    end

    def validation_messages
      [].tap do |keys|
        keys << t("decidim.following.no_followings") if public_followings.blank?
        keys << t("decidim.following.non_public_followings") if non_public_followings?
      end
    end
  end
end
