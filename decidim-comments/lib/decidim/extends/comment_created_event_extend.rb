# frozen-string_literal: true
module CommentCreatedEventExtend
  def email_moderation_intro
    I18n.t(
      "decidim.comments.events.comment_created.#{comment_type}.moderation.email_intro",
      resource_title: resource_title,
      author_name: comment.author.name
    ).html_safe
  end

  def email_moderation_subject
    I18n.t(
      "decidim.comments.events.comment_created.#{comment_type}.moderation.email_subject",
      resource_title: resource_title,
      author_name: comment.author.name
    ).html_safe
  end

  def email_moderation_url(moderation_url)
    I18n.t(
      "decidim.comments.events.comment_created.#{comment_type}.moderation.moderation_url",
      moderation_url: moderation_url
    ).html_safe
  end

  def email_url
    I18n.t(
      "decidim.comments.events.comment_created.#{comment_type}.url",
      resource_url: resource_locator.url(url_params)
    ).html_safe
  end


end

Decidim::Comments::CommentCreatedEvent.class_eval do
  prepend(CommentCreatedEventExtend)
end

