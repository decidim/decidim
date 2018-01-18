# frozen_string_literal: true

module Decidim
  # This cell renders the user's avatar, name, action buttons & potentially
  # anything related to a user. It's used below resource titles to indicate
  # its authorship & such.
  class UserBoxCell < Decidim::ViewModel
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
