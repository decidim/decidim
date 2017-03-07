# frozen_string_literal: true
module Decidim
  # A command with all the business logic when a user creates a report.
  class CreateReport < Rectify::Command
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

      send_report_notification_to_admins

      if hideable?
        hide!
        send_hide_notification_to_admins
      end

      broadcast(:ok, report)
    end

    private

    attr_reader :form, :report

    def create_report!
      @report = Report.create!(
        reportable: @reportable,
        user: @current_user,
        reason: form.reason,
        details: form.details
      )
    end

    def update_report_count!
      @reportable.update_attributes!(report_count: @reportable.report_count + 1)
    end

    def participatory_process_admins
      @participatory_process_admins ||= Decidim::Admin::ProcessAdmins.for(@reportable.feature.participatory_process)
    end

    def send_report_notification_to_admins
      participatory_process_admins.each do |admin|
        ReportedMailer.report(admin, @report).deliver_later
      end
    end

    def hideable?
      !@reportable.hidden? && @reportable.report_count >= Decidim.max_reports_before_hiding
    end

    def hide!
      Decidim::Admin::HideResource.new(@reportable).call
    end

    def send_hide_notification_to_admins
      participatory_process_admins.each do |admin|
        ReportedMailer.hide(admin, @report).deliver_later
      end
    end
  end
end
