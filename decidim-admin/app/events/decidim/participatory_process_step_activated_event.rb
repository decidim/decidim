# frozen-string_literal: true

module Decidim
  class ParticipatoryProcessStepActivatedEvent < Decidim::Events::BaseEvent
    include Decidim::Events::EmailEvent
    include Decidim::Events::NotificationEvent
    include Rails.application.routes.mounted_helpers

    def email_subject
      I18n.t(
        "decidim.events.participatory_process_step_activated_event.email_subject",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      )
    end

    def email_intro
      I18n.t(
        "decidim.events.participatory_process_step_activated_event.email_intro",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      )
    end

    def email_outro
      I18n.t(
        "decidim.events.participatory_process_step_activated_event.email_outro",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      )
    end

    def notification_title
      I18n.t(
        "decidim.events.participatory_process_step_activated_event.notification_title",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      ).html_safe
    end

    private

    def participatory_space
      resource.participatory_process
    end

    def resource_path
      @resource_path ||= decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_space)
    end

    def participatory_space_title
      participatory_space.title[I18n.locale.to_s]
    end
  end
end
