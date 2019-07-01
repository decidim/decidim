# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class DestroyDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # amendment     - The amendment to destroy.
      # current_user  - The current user.
      def initialize(amendment, current_user)
        @amendment = amendment
        @amendable = amendment.amendable
        @emendation = amendment.emendation
        @amender = amendment.amender
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amendable.
      # - :invalid if the amendment is not a draft.
      # - :invalid if the amender is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless amendment.draft? && amender == current_user

        emendation.destroy!
        amendment.delete

        broadcast(:ok, amendable)
      end

      private

      attr_reader :amendment, :amendable, :emendation, :amender, :current_user
    end
  end
end
