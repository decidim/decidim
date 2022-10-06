# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This command is executed when the user updates the conference diploma configuration.
      class UpdateDiploma < Decidim::Command
        # Initializes a UpdateDiploma Command.
        #
        # form - The form from which to get the data.
        # conference - The current instance of the conference to be updated.
        def initialize(form, conference)
          @form = form
          @conference = conference
        end

        # Updates the conference if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          @conference.with_lock do
            update_conference_diploma
            Decidim.traceability.perform_action!(:update_diploma, @conference, form.current_user) do
              @conference
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :conference

        def update_conference_diploma
          @conference.main_logo = @form.main_logo if @form.main_logo.present?
          @conference.signature = @form.signature if @form.signature.present?
          @conference.signature_name = @form.signature_name
          @conference.sign_date = @form.sign_date

          @conference.save!
        end
      end
    end
  end
end
