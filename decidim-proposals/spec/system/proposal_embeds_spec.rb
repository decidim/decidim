# frozen_string_literal: true

require "spec_helper"

describe "Proposal embeds", type: :system do
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let(:resource) { create(:proposal, component: component) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(component).proposal_widget_path(resource) }

  it_behaves_like "an embed resource", skip_publication_checks: true
  it_behaves_like "a moderated embed resource"
  it_behaves_like "a withdrawn embed resource"
end
