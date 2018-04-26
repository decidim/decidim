# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages post", type: :system do
  let(:manifest_name) { "blogs" }
  let!(:post) { create :post, component: current_component }

  include_context "when managing a component as a process admin"

  it_behaves_like "manage posts"
end
