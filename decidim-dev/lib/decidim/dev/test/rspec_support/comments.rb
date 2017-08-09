# frozen_string_literal: true

module CommentsHelpers
  def have_comment_from(user, text)
    within "#comments" do
      have_content(user.name) && have_content(text)
    end
  end

  def have_reply_to(comment, text)
    within "#comments #comment_#{comment.id}" do
      have_content(text)
    end
  end
end

RSpec.configure do |config|
  config.include CommentsHelpers, type: :feature
end
