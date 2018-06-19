# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be able to create
  # private users
  module HasPrivateUsers
    extend ActiveSupport::Concern

    included do
      has_many :participatory_space_private_users, class_name: "Decidim::ParticipatorySpacePrivateUser", as: :privatable_to, dependent: :destroy
      has_many :users, through: :participatory_space_private_users, class_name: "Decidim::User", foreign_key: "private_user_to_id"

      scope :visible_for, lambda { |user|
                            joins("LEFT JOIN decidim_participatory_space_private_users ON
                            decidim_participatory_space_private_users.privatable_to_id = #{table_name}.id")
                              .where("(private_space = ? and decidim_participatory_space_private_users.decidim_user_id = ?) or private_space = ? ", true, user, false).distinct
                          }

      def self.public_spaces
        super.where(private_space: false)
      end
    end
  end
end
