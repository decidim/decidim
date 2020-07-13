# frozen_string_literal: true

require "spec_helper"

describe "Preview elections with share token", type: :system do
  let(:manifest_name) { "elections" }

  include_context "with a component"
  it_behaves_like "preview component with share_token"
end
