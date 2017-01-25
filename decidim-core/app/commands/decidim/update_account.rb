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

      @user.attributes = {
        name: @form.name,
        email: @form.email
      }

      if @form.avatar
        @user.avatar = @form.avatar
      elsif @form.remove_avatar
        @user.remove_avatar = true
      end

      if @form.password.present?
        @user.password = @form.password
        @user.password_confirmation = @form.password_confirmation
      end

      @user.save!

      broadcast(:ok, @form)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end
  end
end
