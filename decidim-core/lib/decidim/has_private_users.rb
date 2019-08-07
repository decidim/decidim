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

          left_outer_joins(:participatory_space_private_users).where(
            %(private_space = false OR
            decidim_participatory_space_private_users.decidim_user_id = ?), user.id
          )
        else
          public_spaces
        end
      end

      def self.public_spaces
        where(private_space: false)
      end

      def self.private_spaces
        where(private_space: true)
      end
    end
  end
end
