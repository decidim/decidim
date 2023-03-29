# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  class GroupMembersCell < MembersCell
    def role = "member"
  end
end
