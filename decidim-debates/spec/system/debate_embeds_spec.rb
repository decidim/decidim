# frozen_string_literal: true

require "spec_helper"

describe "Debate embeds", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }
  let!(:resource) { create(:debate, component: component) }

  it_behaves_like "an embed resource"
end
