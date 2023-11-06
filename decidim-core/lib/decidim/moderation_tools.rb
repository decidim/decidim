# frozen_string_literal: true

# This class contains all the domain logic associated to Decidim's moderation
# system. It is meant to be used both from the admin and the public areas. It
# provides a set of methods to create reports, hide resources, etc.
# Basic usage:
# moderation = Decidim::ModerationTools.new(resource, current_user)
# transaction do
#   moderation.create_report!(reason: "spam", details: "This is a spam")
#   moderation.hide!
#   moderation.send_notification_to_author
#   moderation.update_report_count!
#   moderation.update_reported_content!
# end
module Decidim
  class ModerationTools
    attr_reader :reportable, :current_user

    def initialize(reportable, current_user)
      @reportable = reportable
      @current_user = current_user
    end

    # Public: increments the report count for the moderation object associated with resource
    def update_report_count!
      moderation.update!(report_count: moderation.report_count + 1)
    end

    # Public: fetches the participatory space of the resource's component or from the resource itself
    def participatory_space
      @participatory_space ||= @reportable.component&.participatory_space || @reportable.try(:participatory_space)
    end

    # Public: updates the reported content for the moderation object associated with resource
    def update_reported_content!
      moderation.update!(reported_content: @reportable.reported_searchable_content_text)
    end

    # Public: creates a new report for the given resource, having a basic set of options
    # moderation.create_report!(reason: "spam", details: "This is a spam")
    def create_report!(options)
      options.reverse_merge!(
        moderation:,
        user: @current_user,
        locale: I18n.locale
      )
      Report.create!(options)
    end

    # Public: returns the moderation object for the given resource
    def moderation
      @moderation ||= Moderation.find_or_create_by!(reportable: @reportable, participatory_space:)
    end

    # Public: Broadcasts a notification to the author of the resource that has been hidden
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

    # Public: hides the resource
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
