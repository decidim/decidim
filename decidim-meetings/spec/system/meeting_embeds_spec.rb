# frozen_string_literal: true

require "spec_helper"

describe "Meeting embeds", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:resource) { create(:meeting, :published, component:) }

  it_behaves_like "an embed resource"
end
