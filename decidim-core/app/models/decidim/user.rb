# frozen_string_literal: true
require_dependency "devise/models/decidim_validatable"

module Decidim
  # A User is a citizen that wants to join the platform to participate.
  class User < ApplicationRecord
    devise :invitable, :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :decidim_validatable

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: Decidim::Organization

    ROLES = %w(admin moderator official).freeze

    validates :organization, presence: true
    validate :all_roles_are_valid

    # Public: Allows customizing the invitation instruction email content when
    # inviting a user.
    #
    # Returns a String.
    attr_accessor :invitation_instructions

    # Checks if the user is an admin in the organization it belongs to. This
    # should probably be deleted and add a system to authorize actions.
    #
    # Returns Booolean.
    def admin?
      roles.include?("admin")
    end

    private

    def all_roles_are_valid
      errors.add(:roles, :invalid) unless roles.all? { |role| ROLES.include?(role) }
    end
  end
end
