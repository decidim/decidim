Decidim::NotificationMailer.class_eval do

  def event_received(event, event_class_name, resource, user, extra)
    return unless user.email

    with_user(user) do

      if @extra[:new_content]
        @organization = user.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        subject = @event_instance.email_subject
      else
        @organization = resource.organization
        event_class = event_class_name.constantize
        @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
        @slug = extra[:process_slug]
        @locale = locale.to_s
        subject = @event_instance.email_subject
        @parent_title = parent_title(resource, event_class)
        @resource_title = resource.try(:title)
        @body = body(event_class, resource, extra)
        @is_comment = is_comment?(event_class)
        @translatable =
          if resource.is_a?(Decidim::Budgets::Project) || resource.is_a?(Decidim::Meetings::Meeting)
            true
          elsif resource.is_a?(Decidim::Proposals::Proposal)
            if event_class_name == "Decidim::Proposals::ProposalCreatedEvent"
              true
            else
              false
            end
          end
      end

      mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
      
    end
  end

  def new_content_received(event, event_class_name, resource, user, extra)
    with_user(user) do
      @organization = resource.organization
      event_class = event_class_name.constantize
      @event_instance = event_class.new(resource: resource, event_name: event, user: user, extra: extra)
      @slug = extra[:process_slug]
      @locale = locale.to_s
      subject = @event_instance.email_subject
      @parent_title = parent_title(resource, event_class)
      @resource_title = resource.try(:title)
      @body = body(event_class, resource, extra)
      @is_comment = is_comment?(event_class)
      @translatable =
        if resource.is_a?(Decidim::Budgets::Project) || resource.is_a?(Decidim::Meetings::Meeting)
          true
        elsif resource.is_a?(Decidim::Proposals::Proposal)
          if event_class_name == "Decidim::Proposals::ProposalCreatedEvent"
            true
          else
            false
          end
        end
      mail(from: Decidim.config.mailer_sender, to: user.email, subject: subject)
    end
  end

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
end
