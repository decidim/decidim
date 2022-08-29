# frozen_string_literal: true

require "spec_helper"

describe "Admin manages posts", type: :system do
  let(:manifest_name) { "blogs" }
  let!(:post1) { create :post, component: current_component, author:, title: { en: "Post title 1" } }
  let!(:post2) { create :post, component: current_component, title: { en: "Post title 2" } }
  let(:author) { create :user, organization: }

  include_context "when managing a component as an admin"

  context "when author is the organization" do
    let(:author) { organization }

    it_behaves_like "manage posts"
  end

  context "when author is a user" do
    let(:author) { create :user, organization: }

    it_behaves_like "manage posts"
  end
end
