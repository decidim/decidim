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

      Decidim::User.transaction do
        destroy_user_account!
        destroy_user_identities
        destroy_user_group_memberships
      end

      broadcast(:ok)
    end

    private

    def destroy_user_account!
      @user.name = ""
      @user.email = ""
      @user.delete_reason = @form.delete_reason
      @user.deleted_at = Time.current
      @user.skip_reconfirmation!
      @user.remove_avatar!
      @user.save!
    end

    def destroy_user_identities
      @user.identities.destroy_all
    end

    def destroy_user_group_memberships
      Decidim::UserGroupMembership.where(user: @user).destroy_all
    end
  end
end
