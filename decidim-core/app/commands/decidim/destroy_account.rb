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
        destroy_follows
        destroy_assembly_user_roles
        destroy_assembly_member
        destroy_participatory_space_private_user
        destroy_participatory_process_user_roles
        destroy_conference_user_roles
        destroy_conference_speaker
      end

      broadcast(:ok)
    end

    private

    def destroy_user_account!
      @user.name = ""
      @user.nickname = ""
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

    def destroy_follows
      Decidim::Follow.where(followable: @user).destroy_all
      Decidim::Follow.where(user: @user).destroy_all
    end

    def destroy_assembly_user_roles
      Decidim::AssemblyUserRole.where(user: @user).destroy_all
    end

    def destroy_assembly_member
      Decidim::AssemblyMember.where(user: @user).destroy_all
    end

    def destroy_participatory_space_private_user
      Decidim::ParticipatorySpacePrivateUser.where(user: @user).destroy_all
    end

    def destroy_participatory_process_user_roles
      Decidim::ParticipatoryProcessUserRole.where(user: @user).destroy_all
    end

    def destroy_conference_user_roles
      Decidim::ConferenceUserRole.where(user: @user).destroy_all
    end

    def destroy_conference_speaker
      Decidim::ConferenceSpeaker.where(user: @user).destroy_all
    end
  end
end
