# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper
    helper Decidim::TranslationsHelper

    def event_received(event, event_class_name, resource, user, extra)
      with_user(user) do
        @organization = resource.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        subject = @event_instance.email_subject

        mail(to: user.email, subject: subject)
      end
    end

    def new_content_received(event, event_class_name, resource, user, extra)
      @moderation = extra[:moderation_event]
      with_user(user) do
        @organization = resource.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        @slug = extra[:process_slug]
        @locale = locale.to_s
        subject = @moderation ? @event_instance.email_moderation_subject : @event_instance.email_subject
        @parent_title = parent_title(resource, event_class)
        @resource_title = resource.title if is_proposal?(event_class)
        @body = body(event_class, resource, extra)
        object = is_proposal?(event_class) ? "proposal" : "comment"
        @moderation_url = moderation_url
        @is_proposal = is_proposal?(event_class)
        mail(to: user.email, subject: subject)
      end
    end

    private

    def is_proposal?(event_class)
      event_class == Decidim::Proposals::ProposalCreatedEvent
    end

    def parent_title(resource, event_class)
      if is_proposal?(event_class)
        resource.feature.participatory_space.title
      else
        resource.title
      end
    end

    def body(event_class, resource, extra)
      if is_proposal?(event_class)
        resource.body
      else
        Decidim::Comments::Comment.find(extra[:comment_id]).body
      end
    end

    def moderation_url
      "http://" + @organization.host + "/admin/participatory_processes/" + @slug + "/moderations?locale=" + @locale + "&moderation_type=upstream"
    end
  end
end
