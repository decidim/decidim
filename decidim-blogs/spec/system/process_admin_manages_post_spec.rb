# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages post", type: :system do
  let(:manifest_name) { "blogs" }
  let!(:post1) { create :post, component: current_component, author: author, title: { en: "Post title 1" } }
  let!(:post2) { create :post, component: current_component, title: { en: "Post title 2" } }
  let(:author) { create :user, organization: organization }

  include_context "when managing a component as a process admin"

  it_behaves_like "manage posts"
end
