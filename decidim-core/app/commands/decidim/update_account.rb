# frozen_string_literal: true
module Decidim
  # This command updates the user's account.
  class UpdateAccount < Rectify::Command
    # Updates a user's account.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_personal_data
      update_avatar
      update_password

      @user.save!
      @form.remove_avatar = false
      broadcast(:ok, @user.unconfirmed_email.present?)
    end

    private

    def update_personal_data
      @user.name = @form.name
      @user.email = @form.email
    end

    def update_avatar
      if @form.avatar
        @user.avatar = @form.avatar
      elsif @form.remove_avatar
        @user.remove_avatar = true
      end
    end

    def update_password
      return unless @form.password.present?

      @user.password = @form.password
      @user.password_confirmation = @form.password_confirmation
    end
  end
end
