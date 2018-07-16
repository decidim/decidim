# frozen_string_literal: true

Decidim::NotificationMailer.class_eval do
  def new_content_received(_event, _event_class_name, resource, user, _extra)
    with_user(user) do
      @organization = resource.organization
    end
  end
end
