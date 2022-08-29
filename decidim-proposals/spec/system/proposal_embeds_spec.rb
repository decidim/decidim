# frozen_string_literal: true

require "spec_helper"

describe "Proposal embeds", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:resource) { create(:proposal, component:) }

  it_behaves_like "an embed resource"
end
