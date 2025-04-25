# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ParticipatorySpaceUser
    extend ActiveSupport::Concern

    ROLES = %w(admin collaborator moderator evaluator).freeze

    included do
      validate :user_and_space_same_organization

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true

      ransacker :name do
        Arel.sql(%{("decidim_users"."name")::text})
      end

      ransacker :nickname do
        Arel.sql(%{("decidim_users"."nickname")::text})
      end

      ransacker :email do
        Arel.sql(%{("decidim_users"."email")::text})
      end

      ransacker :invitation_accepted_at do
        Arel.sql(%{("decidim_users"."invitation_accepted_at")::text})
      end

      ransacker :last_sign_in_at do
        Arel.sql(%{("decidim_users"."last_sign_in_at")::text})
      end

      def target_space_association
        raise "Not implemented"
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(name nickname email invitation_accepted_at last_sign_in_at role)
      end

      def self.ransackable_associations(_auth_object = nil)
        []
      end

      def self.order_by_name
        includes(:user).order("decidim_users.name ASC")
      end

      private

      # Private: check if the process and the user have the same organization
      def user_and_space_same_organization
        return if !send(target_space_association) || !user

        errors.add(target_space_association, :invalid) unless user.organization == send(target_space_association).organization
      end
    end
  end
end
