module NotificationMailerExtend
  def self.included(base)
    base.send(:include, ModerationsNotifications)
  end

  module ModerationsNotifications
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
        @resource_title = resource.try(:title)
        @body = body(event_class, resource, extra)
        @moderation_url = moderation_url
        @is_comment = is_comment?(event_class)
        mail(to: user.email, subject: subject)
      end
    end

    private

    def is_comment?(event_class)
      event_class == Decidim::Comments::CommentCreatedEvent
    end

    def parent_title(resource, event_class)
      if is_comment?(event_class)
        resource.title
      else
        resource.feature.participatory_space.title
      end
    end

    def body(event_class, resource, extra)
      if is_comment?(event_class)
        Decidim::Comments::Comment.find(extra[:comment_id]).body
      else
        resource.body
      end
    end

    def moderation_url
      "http://" + @organization.host + "/admin/participatory_processes/" + @slug + "/moderations?locale=" + @locale + "&moderation_type=upstream"
    end
  end
end

Decidim::NotificationMailer.send(:include, NotificationMailerExtend)
