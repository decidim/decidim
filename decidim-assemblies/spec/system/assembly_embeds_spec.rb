# frozen_string_literal: true

require "spec_helper"

describe "Assembly embeds", type: :system do
  let(:resource) { create(:assembly) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(resource).assembly_widget_path }

  it_behaves_like "an embed resource", skip_space_checks: true
  it_behaves_like "a private embed resource"
  it_behaves_like "a transparent private embed resource"
end
