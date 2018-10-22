# frozen_string_literal: true

module Decidim
  # This cell renders the profile of the given membership.
  class UserGroupMembershipProfileCell < Decidim::UserProfileCell
    def user
      model.user
    end
  end
end
