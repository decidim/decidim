# frozen_string_literal: true

require "spec_helper"

describe "like posts" do
  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let(:organization) { create(:organization) }
  let!(:post) { create(:post, author: user, component:, title: { en: "Blog post title" }) }
  let!(:resource) { post }
  let!(:resource_name) { translated(post.title) }

  let!(:component) do
    create(:post_component,
           *component_traits,
           manifest:,
           participatory_space:)
  end

  it_behaves_like "Like resource system specs"
end
