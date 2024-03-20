# frozen_string_literal: true

require "spec_helper"

describe "Debate embeds", type: :system do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:resource) { create(:debate, component: component, skip_injection: true) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(component).debate_widget_path(resource) }

  it_behaves_like "an embed resource", skip_publication_checks: true
  it_behaves_like "a moderated embed resource"
end
