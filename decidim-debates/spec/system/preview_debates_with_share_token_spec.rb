# frozen_string_literal: true

require "spec_helper"

describe "preview debates with a share token" do
  let(:manifest_name) { "debates" }

  include_context "with a component"
  it_behaves_like "preview component with a share_token"
end
