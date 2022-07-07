# frozen_string_literal: true

module CommentsHelpers
  def have_comment_from(user, text, opts = {})
    within "#comments" do
      have_content(user.name, **opts) && have_content(text, **opts)
    end
  end

  def have_reply_to(comment, text)
    within "#comments #comment_#{comment.id}" do
      have_content(text)
    end
  end
end

RSpec.configure do |config|
  config.include CommentsHelpers, type: :system
end
