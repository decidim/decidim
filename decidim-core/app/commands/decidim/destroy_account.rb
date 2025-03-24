# frozen_string_literal: true

module Decidim
  # This command destroys the user's account.
  class DestroyAccount < Decidim::Command
    delegate :current_user, to: :form

    # Destroy a user's account.
    #
    # form - The form with the data.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      Decidim::User.transaction do
        destroy_user_account!
        destroy_user_identities
        destroy_follows
        destroy_participatory_space_private_user
        delegate_destroy_to_participatory_spaces
      end

      broadcast(:ok)
    end

    private

    attr_reader :form

    def destroy_user_account!
      current_user.invalidate_all_sessions!

      current_user.name = ""
      current_user.nickname = ""
      current_user.email = ""
      current_user.personal_url = ""
      current_user.about = ""
      current_user.notifications_sending_frequency = "none"
      current_user.delete_reason = @form.delete_reason
      current_user.admin = false if current_user.admin?
      current_user.deleted_at = Time.current
      current_user.skip_reconfirmation!
      current_user.avatar.purge
      current_user.save!
    end

    def destroy_user_identities
      current_user.identities.destroy_all
    end

    def destroy_follows
      Decidim::Follow.where(followable: current_user).destroy_all
      Decidim::Follow.where(user: current_user).destroy_all
    end

    def destroy_participatory_space_private_user
      Decidim::ParticipatorySpacePrivateUser.where(user: current_user).destroy_all
    end

    def delegate_destroy_to_participatory_spaces
      Decidim.participatory_space_manifests.each do |space_manifest|
        space_manifest.invoke_on_destroy_account(current_user)
      end
    end
  end
end
