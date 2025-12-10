# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    module ParticipatorySpace
      class ImportMemberCsv < Decidim::Command
        include Decidim::Admin::CustomImport

        delegate :current_user, to: :form
        # Public: Initializes the command.
        #
        # form - the form object containing the uploaded file
        # members_to - The members_to that will hold the user role
        def initialize(form, members_to)
          @form = form
          @members_to = members_to
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
            ImportMemberCsvJob.perform_later(email, user_name, @members_to, current_user) if email.present? && user_name.present?
          end
        end
      end
    end
  end
end
