Decidim::NotificationMailer.class_eval do
  def new_content_received(event, event_class_name, resource, user, extra)
    with_user(user) do
      @organization = resource.organization

    end
  end
end
