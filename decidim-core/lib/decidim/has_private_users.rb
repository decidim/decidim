# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be able to create
  # private users
  module HasPrivateUsers
    extend ActiveSupport::Concern

    included do
      has_many :participatory_space_private_users,
               class_name: "Decidim::ParticipatorySpacePrivateUser",
               as: :privatable_to,
               dependent: :destroy
      has_many :users,
               through: :participatory_space_private_users,
               class_name: "Decidim::User",
               foreign_key: "private_user_to_id"

      def self.visible_for(user)
        if user
          return all if user.admin?

          where(
            id: public_spaces +
                private_spaces
                  .joins(:participatory_space_private_users)
                  .where(decidim_participatory_space_private_users: { decidim_user_id: user.id })
          )
        else
          public_spaces
        end
      end

      def can_participate?(user)
        return true unless private_space?
        return false unless user

        participatory_space_private_users.exists?(decidim_user_id: user.id)
      end

      def self.public_spaces
        where(private_space: false).published
      end

      def self.private_spaces
        where(private_space: true)
      end
    end
  end
end
