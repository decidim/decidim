# frozen_string_literal: true

require "spec_helper"

describe "Sortition embeds", type: :system do
  include_context "with a component"
  let(:manifest_name) { "sortitions" }
  let(:resource) { create(:sortition, component:) }

  it_behaves_like "an embed resource"
end
