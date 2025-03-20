# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class VerifyUserGroupFromCsvJob < ApplicationJob
      queue_as :default

      def perform(email, verifier, organization)
        @organization = organization
        @email = email.downcase.strip

        return if email.blank?
        return unless user_group

        Decidim::Admin::VerifyUserGroup.call(user_group, verifier, via_csv: true)
      end

      private

      def user_group
        @user_group ||= UserGroup.where(organization: @organization)
                                 .where.not(confirmed_at: nil)
                                 .not_verified
                                 .find_by(email: @email)
      end
    end
  end
end
