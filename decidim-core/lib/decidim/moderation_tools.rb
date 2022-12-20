# frozen_string_literal: true

module Decidim
  class ModerationTools
    attr_reader :reportable, :current_user

    def initialize(reportable, current_user)
      @reportable = reportable
      @current_user = current_user
    end

    def update_report_count!
      moderation.update!(report_count: moderation.report_count + 1)
    end

    def participatory_space
      @participatory_space ||= @reportable.component&.participatory_space || @reportable.try(:participatory_space)
    end

    def update_reported_content!
      moderation.update!(reported_content: @reportable.reported_searchable_content_text)
    end

    def create_report!(options)
      options.reverse_merge!(
        moderation:,
        user: @current_user,
        locale: I18n.locale
      )
      Report.create!(options)
    end

    def moderation
      @moderation ||= Moderation.find_or_create_by!(reportable: @reportable, participatory_space:)
    end

    def send_notification_to_author
      data = {
        event: "decidim.events.reports.resource_hidden",
        event_class: Decidim::ResourceHiddenEvent,
        resource: @reportable,
        extra: {
          report_reasons:
        },
        affected_users: @reportable.try(:authors) || [@reportable.try(:normalized_author)]
      }

      Decidim::EventsManager.publish(**data)
    end

    def hide!
      Decidim.traceability.perform_action!(
        "hide",
        moderation,
        @current_user,
        extra: {
          reportable_type: @reportable.class.name
        }
      ) do
        @reportable.moderation.update!(hidden_at: Time.current)
        @reportable.try(:touch)
      end
    end

    private

    def report_reasons
      @reportable.moderation.reports.pluck(:reason).uniq
    end
  end
end
