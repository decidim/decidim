# frozen_string_literal: true

module Decidim
  # A command with all the business logic when a user creates a report.
  class CreateUserReport < Rectify::Command
    # Public: Initializes the command.
    #
    # form         - A form object with the params.
    # reportable   - The resource being reported
    # current_user - The current user.
    def initialize(form, reportable, current_user)
      @form = form
      @reportable = reportable
      @current_user = current_user
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the report.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      transaction do
        create_report!
        update_report_count!
      end

      send_email_to_moderators

      broadcast(:ok, report)
    end

    private

    attr_reader :form, :report

    def create_report!
      @report = UserReport.create!(
        reporter: @current_user,
        reported: @reportable,
        reason: form.reason,
        details: form.details
      )
    end

    def update_report_count!
      @reportable.increment!(:report_count)
    end

    def send_email_to_moderators
      # participatory_space_moderators.each do |moderator|
      #   ReportedMailer.report(moderator, @report).deliver_later
      # end
    end

    def hideable?
      false
    end
  end
end
