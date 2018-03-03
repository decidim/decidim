# frozen_string_literal: true

module Decidim
  # This cell renders the avatar, name and nickname of
  # the given user or user group, and adds some links
  # to potential actions on the given profile.
  class ProfileCell < Decidim::ViewModel
    include LayoutHelper
    include Messaging::ConversationHelper

    def show
      render
    end

    def user_signed_in?
      parent_controller.user_signed_in?
    end

    def current_user
      parent_controller.current_user
    end
  end
end
