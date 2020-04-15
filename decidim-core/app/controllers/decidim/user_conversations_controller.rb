# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserConversationsController < Decidim::ApplicationController
    include Paginable
    include UserGroups

    helper Decidim::ResourceHelper
    helper_method :user

    private

    def user
      @user ||= Decidim::UserBaseEntity.find_by(nickname: params[:nickname], organization: current_organization)
    end
  end
end
