# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    class ProcessParticipatorySpacePrivateUserImportCsv < Decidim::Command
      include Decidim::Admin::CustomImport

      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # form - the form object containing the uploaded file
      # private_users_to - The private_users_to that will hold the user role
      def initialize(form, private_users_to)
        @form = form
        @private_users_to = private_users_to
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @form.valid?

        process_csv
        broadcast(:ok)
      end

      private

      attr_reader :form

      def process_csv
        process_import_file(@form.file) do |(email, user_name)|
          ImportParticipatorySpacePrivateUserCsvJob.perform_later(email, user_name, @private_users_to) if email.present? && user_name.present?
        end
      end
    end
  end
end
