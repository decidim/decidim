# frozen_string_literal: true

require "spec_helper"

describe "Preview proposals with share token" do
  let(:manifest_name) { "proposals" }

  include_context "with a component"
  it_behaves_like "preview component with share_token"
end
