# frozen_string_literal: true

module Decidim
  class RedesignedFollowingCell < RedesignedFollowersCell
    def followers
      @followers ||= Kaminari.paginate_array(model.public_users_followings).page(params[:page]).per(20)
    end
  end
end
