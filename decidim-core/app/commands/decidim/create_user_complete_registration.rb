# frozen_string_literal: true

module Decidim
  # A command with all the business logic to complete a user registration through a form.
  class CreateUserCompleteRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # user - The user to be updated.
    # form - A form object with the params.
    def initialize(user, form)
      @user = user
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns unconfirmed email flag.
    def call
      return broadcast(:invalid) unless @form.valid?

      update_personal_data
      update_avatar
      update_interests
      @user.save!

      broadcast(:ok, @user.unconfirmed_email.present?)
    rescue ActiveRecord::RecordInvalid
      @form.errors.add :avatar, @user.errors[:avatar] if @user.errors.has_key? :avatar
      broadcast(:invalid)
    end

    private

    def update_personal_data
      @user.personal_url = @form.personal_url
      @user.about = @form.about
    end

    def update_avatar
      @user.avatar = @form.avatar
      @user.remove_avatar = @form.remove_avatar
    end

    def update_interests
      @user.extended_data ||= {}
      @user.extended_data["interested_scopes"] = selected_scopes_ids
    end

    def selected_scopes_ids
      @form.scopes.select(&:checked).map(&:id)
    end
  end
end
