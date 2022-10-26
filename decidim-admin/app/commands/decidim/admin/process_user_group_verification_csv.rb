# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    # A command with all the business logic when processing the CSV to verify
    # user groups.
    class ProcessUserGroupVerificationCsv < Decidim::Command
      include Decidim::Admin::CustomImport

      # Public: Initializes the command.
      #
      # form - the form object containing the uploaded file
      def initialize(form)
        @form = form
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
        verifier = @form.current_user
        organization = @form.current_organization

        process_import_file(@form.file) do |(email)|
          VerifyUserGroupFromCsvJob.perform_later(email, verifier, organization) if email.present?
        end
      end
    end
  end
end
