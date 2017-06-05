# frozen_string_literal: true

module Decidim
  # This command destroys the user's account.
  class DestroyAccount < Rectify::Command
    # Destroy a user's account.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      destroy_user_account!
      broadcast(:ok)
    end

    private

    def destroy_user_account!
      @user.email = "deleted-user-#{SecureRandom.uuid}@example.org"
      @user.delete_reason = @form.delete_reason
      @user.deleted_at = Time.current
      @user.skip_reconfirmation!
      @user.save!
    end
  end
end
