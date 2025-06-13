# frozen_string_literal: true

module Decidim
  # A command with all the business logic when a user creates a report.
  class CreateReport < Decidim::Command
    delegate :current_user, to: :form

    # Public: Initializes the command.
    #
    # form         - A form object with the params.
    # reportable   - The resource being reported
    def initialize(form, reportable)
      @form = form
      @reportable = reportable
      @tool = Decidim::ModerationTools.new(reportable, current_user)
    end

    delegate :moderation, :participatory_space, :update_reported_content!, :update_report_count!, to: :tool
    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the report.
    # - :invalid if the form was not valid and we could not proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      transaction do
        update_reported_content!
        create_report!
        update_report_count!
      end

      send_report_notification_to_moderators

      if hideable?
        @tool.hide!
        send_hide_notification_to_moderators
      end

      broadcast(:ok, report)
    end

    private

    attr_reader :form, :report, :tool

    def create_report!
      @report = @tool.create_report!({
                                       reason: form.reason,
                                       details: form.details
                                     })
    end

    def participatory_space_moderators
      @participatory_space_moderators ||= participatory_space.respond_to?(:moderators) ? participatory_space.moderators : []
    end

    def send_report_notification_to_moderators
      participatory_space_moderators.each do |moderator|
        next unless moderator.email_on_moderations

        ReportedMailer.report(moderator, @report).deliver_later
      end
    end

    def hidden_by_admin?
      form.hide == true && form.context[:can_hide] == true
    end

    def hideable?
      hidden_by_admin? || hidden_by_spam_engine? || (!@reportable.hidden? && moderation.report_count >= Decidim.max_reports_before_hiding)
    end

    def hidden_by_spam_engine?
      form.hide == true && form.context[:marked_as_spam] == true
    end

    def send_hide_notification_to_moderators
      participatory_space_moderators.each do |moderator|
        next unless moderator.email_on_moderations

        if hidden_by_admin?
          ReportedMailer.hidden_manually(moderator, @report, current_user).deliver_later
        else
          ReportedMailer.hidden_automatically(moderator, @report).deliver_later
        end
      end
    end
  end
end
