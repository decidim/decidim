# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create an ephemeral user.
  class DestroyEphemeralUser < Decidim::Command
    # Public: Initializes the command.
    #
    # user - An ephemeral user.
    def initialize(user)
      @user = user
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the user is not ephemeral
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless user.ephemeral?

      destroy_pending_authorizations!
      destroy_account!

      broadcast(:ok)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end

    private

    attr_reader :user

    def destroy_pending_authorizations!
      Decidim::Authorization.where(user:, granted_at: nil).destroy_all
    end

    def destroy_account!
      user.invalidate_all_sessions!

      user.delete_reason = "Ephemeral user session expired"
      user.deleted_at = Time.current
      user.skip_reconfirmation!
      user.save!
    end
  end
end
