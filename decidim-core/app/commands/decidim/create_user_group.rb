# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user group.
  class CreateUserGroup < Decidim::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      transaction do
        create_user_group
        create_membership
      end
      notify_admins

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :form

    def create_user_group
      @user_group = UserGroup.create!(
        email: form.email,
        name: form.name,
        nickname: form.nickname,
        organization: form.current_organization,
        about: form.about,
        avatar: form.avatar,
        extended_data: {
          phone: form.phone,
          document_number: form.document_number
        }
      )
    end

    def create_membership
      UserGroupMembership.create!(
        user: form.current_user,
        role: "creator",
        user_group: @user_group
      )
    end

    def notify_admins
      data = {
        event: "decidim.events.groups.user_group_created",
        event_class: Decidim::UserGroupCreatedEvent,
        resource: @user_group,
        affected_users: Decidim::User.org_admins_except_me(form.current_user)
      }

      Decidim::EventsManager.publish(**data)
    end
  end
end
