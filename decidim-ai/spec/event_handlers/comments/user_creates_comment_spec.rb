# frozen_string_literal: true

require "spec_helper"

describe "User creates comment", type: :system do
  let(:form_params) do
    {
      "comment" => {
        "body" => body,
        "alignment" => 1,
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
  let(:command) { Decidim::Comments::CreateComment.new(form) }

  include_examples "comments spam analysis"
end
