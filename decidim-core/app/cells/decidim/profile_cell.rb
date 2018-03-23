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

    delegate :user_signed_in?, :current_user, to: :parent_controller
  end
end
