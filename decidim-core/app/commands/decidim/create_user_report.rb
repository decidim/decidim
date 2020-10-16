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
        find_or_create_moderation!
        create_report!
        update_report_count!
        send_notification_to_admins!
      end

      broadcast(:ok, report)
    end

    private

    attr_reader :form, :report

    def find_or_create_moderation!
      @moderation = UserModeration.find_or_create_by!(user: @reportable)
    end

    def create_report!
      @report = UserReport.create!(
        moderation: @moderation,
        user: @current_user,
        reason: form.reason,
        details: form.details
      )
    end

    def update_report_count!
      @moderation.update!(report_count: @moderation.report_count + 1)
    end

    def send_notification_to_admins!
      current_organization.admins.each do |admin|
        Decidim::UserReportJob.perform_later(admin, current_user, form.reason, reportable)
      end
    end

    def hideable?
      false
    end
  end
end
