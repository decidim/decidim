# frozen_string_literal: true

module CommentsHelpers
  def have_comment_from(user, text, opts = {})
    within "#comments" do
      have_text(decidim_sanitize_translated(user.name).gsub("\n", " "), **opts).and have_text(text, **opts)
    end
  end

  def have_reply_to(comment, text)
    within "#comments #comment_#{comment.id}" do
      have_text(text)
    end
  end
end

RSpec.configure do |config|
  config.include CommentsHelpers, type: :system
end
