# frozen_string_literal: true

require "spec_helper"

describe "Initiative embeds", type: :system do
  let(:resource) { create(:initiative) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(resource).initiative_widget_path }

  it_behaves_like "an embed resource", skip_space_checks: true
end
