# frozen_string_literal: true

module Decidim
  # A command with all the business logic to update a user group profile.
  class UpdateUserGroup < Decidim::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # user_group - The user group to update
    def initialize(form, user_group)
      @form = form
      @user_group = user_group
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      was_verified = user_group.verified?
      update_user_group
      notify_admins if was_verified

      broadcast(:ok, user_group)
    end

    private

    attr_reader :form, :user_group

    def update_user_group
      user_group_attributes = attributes
      user_group_attributes.delete(:avatar) if form.avatar.blank?
      user_group.update(user_group_attributes)
    end

    def attributes
      {
        email: form.email,
        name: form.name,
        nickname: form.nickname,
        about: form.about,
        avatar: form.avatar,
        extended_data: {
          phone: form.phone,
          document_number: form.document_number
        }
      }
    end

    def notify_admins
      data = {
        event: "decidim.events.groups.user_group_updated",
        event_class: Decidim::UserGroupUpdatedEvent,
        resource: @user_group,
        affected_users: Decidim::User.org_admins_except_me(form.current_user)
      }

      Decidim::EventsManager.publish(**data)
    end
  end
end
