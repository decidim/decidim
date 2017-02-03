# frozen_string_literal: true
module Decidim
  # A command with all the business logic to create a user through the sign up form.
  # It enables the option to sign up as a user group.
  class CreateRegistration < Rectify::Command
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
        create_user
        create_user_group if form.is_user_group?
      end

      broadcast(:ok, @user)
    end

    private

    attr_reader :form

    def create_user
      @user = User.create!(email: form.email,
                           name: form.name,
                           password: form.password,
                           password_confirmation: form.password_confirmation,
                           organization: form.current_organization,
                           tos_agreement: form.tos_agreement,
                           comments_notifications: true,
                           replies_notifications: true)
    end

    def create_user_group
      UserGroupMembership.create!(user: @user,
                                  user_group: UserGroup.new(name: form.user_group_name,
                                                            document_number: form.user_group_document_number,
                                                            phone: form.user_group_phone))
    end
  end
end
