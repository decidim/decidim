# frozen_string_literal: true

module Decidim
  # A UserGroupMembership associate user with user groups
  class UserGroupMembership < ApplicationRecord
    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :user_group, class_name: "Decidim::UserGroup", foreign_key: :decidim_user_group_id
  end
end
