# frozen_string_literal: true

require "spec_helper"

describe "Sortition embeds", type: :system do
  include_context "with a component"

  let(:manifest_name) { "sortitions" }
  let(:resource) { create(:sortition, component: component) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(component).sortition_widget_path(resource) }

  it_behaves_like "an embed resource", skip_publication_checks: true
end
