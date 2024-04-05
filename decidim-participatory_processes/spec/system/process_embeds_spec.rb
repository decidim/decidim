# frozen_string_literal: true

require "spec_helper"

describe "Process embeds", type: :system do
  let(:resource) { create(:participatory_process) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(resource).participatory_process_widget_path }

  it_behaves_like "an embed resource", skip_space_checks: true
  it_behaves_like "a private embed resource"
end
