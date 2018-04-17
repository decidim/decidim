# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private ParticipatorySpacePrivateUser
  class ParticipatorySpacePrivateUser < ApplicationRecord
    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :privatable_to, polymorphic: true

    validate :user_and_participatory_space_same_organization

    private

    # Private: check if the participatory space and the user have the same organization
    def user_and_participatory_space_same_organization
      return if !privatable_to || !user
      errors.add(:privatable_to, :invalid) unless user.organization == privatable_to.organization
    end
  end
end
