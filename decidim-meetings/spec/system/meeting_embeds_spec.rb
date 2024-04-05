# frozen_string_literal: true

require "spec_helper"

describe "Meeting embeds", type: :system do
  include_context "with a component"

  let(:manifest_name) { "meetings" }
  let!(:resource) { create(:meeting, :published, component: component) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(component).meeting_widget_path(resource) }

  it_behaves_like "an embed resource"
  it_behaves_like "a moderated embed resource"
  it_behaves_like "a withdrawn embed resource"
end
