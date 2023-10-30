# frozen_string_literal: true

require "spec_helper"

describe "Preview sortitions with share token" do
  let(:manifest_name) { "sortitions" }

  include_context "with a component"
  it_behaves_like "preview component with share_token"
end
