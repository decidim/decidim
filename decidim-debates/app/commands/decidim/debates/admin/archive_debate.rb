# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # A command with all the business logic when an admin archives a debate.
      class ArchiveDebate < Rectify::Command
        # Public: Initializes the command.
        #
        # archive        - Boolean, whether to archive (true) or unarchive (false) the debate.
        # debate         - The debate object to archive.
        # user           - The user performing the action.
        def initialize(archive, debate, user)
          @archive = archive
          @debate = debate
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when the debate is valid.
        # - :invalid if the debate wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          archive_debate
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        attr_reader :debate

        private

        def archive_debate
          @debate = Decidim.traceability.perform_action!(
            :close,
            @debate,
            @user
          ) do
            @debate.update!(
              archived_at: @archive ? Time.zone.now : nil
            )
          end
        end
      end
    end
  end
end
