module ModerationExtend
  def authorized?
    upstream_moderation == "authorized"
  end

  def unmoderated?
    upstream_moderation == "unmoderate"
  end

  def authorize!
    update_attributes(upstream_moderation: "authorized")
    reportable.send_notification if reportable.class.name.demodulize == "Comment"
  end

  def refuse!
    update_attributes(upstream_moderation: "refused")
  end

  def upstream_activated?
    if reportable.is_a?(Decidim::Proposals::Proposal)
      reportable.feature.settings.upstream_moderation_enabled
    else
      reportable.root_commentable.feature.settings.comments_upstream_moderation_enabled
    end
  end
end

Decidim::Moderation.class_eval do
  prepend(ModerationExtend)
end
