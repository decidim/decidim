# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  class GroupAdminsCell < MembersCell
    def role = "admin"
  end
end
