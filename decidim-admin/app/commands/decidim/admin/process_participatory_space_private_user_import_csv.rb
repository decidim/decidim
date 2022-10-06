# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    class ProcessParticipatorySpacePrivateUserImportCsv < Decidim::Command
      include Decidim::ProcessesFileLocally

      # Public: Initializes the command.
      #
      # form - the form object containing the uploaded file
      # current_user - the user performing the action
      # private_users_to - The private_users_to that will hold the user role
      def initialize(form, current_user, private_users_to)
        @form = form
        @current_user = current_user
        @private_users_to = private_users_to
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @form.valid?

        process_csv
        broadcast(:ok)
      end

      private

      def process_csv
        process_file_locally(@form.file) do |file_path|
          CSV.foreach(file_path, encoding: "BOM|UTF-8") do |email, user_name|
            ImportParticipatorySpacePrivateUserCsvJob.perform_later(email, user_name, @private_users_to, @current_user) if email.present? && user_name.present?
          end
        end
      end
    end
  end
end
