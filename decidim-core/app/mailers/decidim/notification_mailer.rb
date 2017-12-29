# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper
    helper Decidim::TranslationsHelper

    def event_received(event, event_class_name, resource, user, extra)
      moderation = extra[:moderation_event]
      template = moderation ? "event_to_moderate_received" : "event_received"
      with_user(user) do
        @organization = resource.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        @slug = extra[:process_slug]
        @locale = locale.to_s
        subject = moderation ? @event_instance.email_moderation_subject : @event_instance.email_subject
        @parent_title = if is_proposal?(resource)
                          resource.feature.participatory_space.title
                        else
                          resource.title
                        end

        @resource_title = resource.title if is_proposal?(resource)
        @body = if is_proposal?(resource)
                   resource.body
                else
                  Decidim::Comments::Comment.find(extra[:comment_id]).body
                end
        @moderation_url = "http://" + @organization.host + "/admin/participatory_processes/" + @slug + "/moderations?locale=" + @locale + "&moderation_type=upstream"
        @is_proposal = is_proposal?(resource)
        mail(to: user.email, subject: subject, :template_name => template)
      end
    end

    def is_proposal?(resource)
      resource.is_a?(Decidim::Proposals::ProposalCreatedEvent) || resource.is_a?(Decidim::Proposals::Proposal )
    end
  end
end
