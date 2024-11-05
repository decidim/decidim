# frozen_string_literal: true

require "spec_helper"

describe "User updates comment", type: :system do
  let(:form_params) do
    {
      "comment" => {
        "body" => body,
        "commentable" => commentable
      }
    }
  end
  let(:form) do
    Decidim::Comments::CommentForm.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: author
    )
  end
  let(:command) { Decidim::Comments::UpdateComment.new(comment, form) }

  include_examples "comments spam analysis" do
    let(:comment) { create(:comment, author:, commentable:) }
  end
end
