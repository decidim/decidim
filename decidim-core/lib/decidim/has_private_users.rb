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
    end
  end
end
