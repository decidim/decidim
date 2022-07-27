# frozen_string_literal: true

module Decidim
  # A command with all the business logic when a user creates a report.
  class CreateReport < Decidim::Command
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
        update_reported_content!
        create_report!
        update_report_count!
      end

      send_report_notification_to_moderators

      if hideable?
        hide!
        send_hide_notification_to_moderators
      end

      broadcast(:ok, report)
    end

    private

    attr_reader :form, :report

    def find_or_create_moderation!
      @moderation = Moderation.find_or_create_by!(reportable: @reportable, participatory_space:)
    end

    def update_reported_content!
      @moderation.update!(reported_content: @reportable.reported_searchable_content_text)
    end

    def create_report!
      @report = Report.create!(
        moderation: @moderation,
        user: @current_user,
        reason: form.reason,
        details: form.details,
        locale: I18n.locale
      )
    end

    def update_report_count!
      @moderation.update!(report_count: @moderation.report_count + 1)
    end

    def participatory_space_moderators
      @participatory_space_moderators ||= participatory_space.moderators
    end

    def send_report_notification_to_moderators
      participatory_space_moderators.each do |moderator|
        next unless moderator.email_on_moderations

        ReportedMailer.report(moderator, @report).deliver_later
      end
    end

    def hideable?
      !@reportable.hidden? && @moderation.report_count >= Decidim.max_reports_before_hiding
    end

    def hide!
      Decidim::Admin::HideResource.new(@reportable, @current_user).call
    end

    def send_hide_notification_to_moderators
      participatory_space_moderators.each do |moderator|
        next unless moderator.email_on_moderations

        ReportedMailer.hide(moderator, @report).deliver_later
      end
    end

    def participatory_space
      @participatory_space ||= @reportable.component&.participatory_space || @reportable.try(:participatory_space)
    end
  end
end
