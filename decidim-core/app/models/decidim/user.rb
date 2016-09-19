# frozen_string_literal: true
module Decidim
  # A User is a citizen that wants to join the platform to participate.
  class User < ApplicationRecord
    devise :invitable, :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: Decidim::Organization

    ROLES = %w(admin moderator official).freeze

    validates :organization, presence: true
    validates :roles, inclusion: { in: ROLES }, allow_blank: true

    # Checks if the user is an admin in the organization it belongs to. This
    # should probably be deleted and add a system to authorize actions.
    #
    # Returns Booolean.
    def admin?
      roles.include?("admin")
    end
  end
end
