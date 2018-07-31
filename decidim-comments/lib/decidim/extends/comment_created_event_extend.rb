# frozen_string_literal: true

module CommentCreatedEventExtend
  def email_url
    I18n.t(
      "decidim.events.comments.comment_created.#{comment_type}.url",
      resource_url: resource_locator.url(url_params)
    ).html_safe
  end
end

Decidim::Comments::CommentCreatedEvent.class_eval do
  prepend(CommentCreatedEventExtend)
end
