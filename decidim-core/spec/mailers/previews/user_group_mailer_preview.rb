# frozen_string_literal: true

module Decidim
  class UserGroupMailerPreview < ActionMailer::Preview
    def notify_deprecation_to_owner
      UserGroupMailer.notify_deprecation_to_owner(group)
    end

    def notify_deprecation_to_member
      UserGroupMailer.notify_deprecation_to_member(user, group.name, group.email)
    end

    private

    def user
      @user ||= Decidim::User.new(name: "John Doe", email: "john.doe@example.org", organization:)
    end

    def group
      @group ||= Decidim::User.new(name: "Demo Group", email: "group@example.org", organization:, extended_data: { group: true })
    end

    def password
      Random.alphanumeric(15)
    end

    def organization
      @organization ||= Decidim::Organization.first
    end
  end
end
