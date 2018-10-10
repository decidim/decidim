# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user group.
  class CreateUserGroup < Rectify::Command
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
        user_group: @user_group
      )
    end
  end
end
