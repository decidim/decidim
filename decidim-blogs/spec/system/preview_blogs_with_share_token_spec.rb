# frozen_string_literal: true

require "spec_helper"

describe "preview blogs with a share token" do
  let(:manifest_name) { "blogs" }

  include_context "with a component"
  it_behaves_like "preview component with a share_token"
end
