# frozen_string_literal: true

require "spec_helper"

describe "preview proposals with a share token" do
  let(:manifest_name) { "proposals" }

  include_context "with a component"
  it_behaves_like "preview component with a share_token"
end
