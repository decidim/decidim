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

      if @user.valid?
        @user.save!
        broadcast(:ok, @user.unconfirmed_email.present?)
      else
        if @user.errors.has_key? :avatar
          @form.errors.add :avatar, @user.errors[:avatar]
        end
        broadcast(:invalid)
      end
    end

    private

    def update_personal_data
      @user.name = @form.name
      @user.email = @form.email
    end

    def update_avatar
      @user.avatar = @form.avatar
      @user.remove_avatar = @form.remove_avatar
    end

    def update_password
      return if @form.password.blank?

      @user.password = @form.password
      @user.password_confirmation = @form.password_confirmation
    end
  end
end
