module EmailNotificationGeneratorExtend
  def send_email_to(recipient_id)
    recipient = Decidim::User.where(id: recipient_id).first
    return unless recipient
    return unless recipient.email_on_notification?
    if @extra[:new_content]
      Decidim::NotificationMailer
        .new_content_received(
          event,
          event_class.name,
          resource,
          recipient,
          extra
        )
        .deliver_later
    else
      Decidim::NotificationMailer
        .event_received(
          event,
          event_class.name,
          resource,
          recipient,
          extra
        )
        .deliver_later
    end
  end
end

Decidim::EmailNotificationGenerator.class_eval do
  prepend(EmailNotificationGeneratorExtend)
end
