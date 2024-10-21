# frozen_string_literal: true

module Decidim
  module Admin
    class UnpublishAllParticipatorySpacePrivateUsers < Decidim::Command
      # Public: Initializes the command.
      #
      # participatory_space - the participatory space
      def initialize(participatory_space)
        @participatory_space = participatory_space
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        unpublish_all
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :participatory_space

      def unpublish_all
        participatory_space.participatory_space_private_users.each do |private_user|
          private_user.update(published: false)
        end
      end
    end
  end
end
