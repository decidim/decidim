# frozen_string_literal: true

require "spec_helper"

describe "global engines", type: :system do
  let(:organization) { create(:organization) }
  let(:mount_at) { nil }

  around do |example|
    Decidim.register_global_engine(:global_engine, Decidim::DummyResources::DummyEngine, at: mount_at)
    Rails.application.reload_routes!
    switch_to_host(organization.host)
    example.run
    Decidim.unregister_global_engine(:global_engine)
    Rails.application.reload_routes!
  end

  it "renders the engine" do
    visit decidim.global_engine_path
    expect(page).to have_content("DUMMY ENGINE")
  end

  it "mounts the engine under a route with its own name" do
    expect(decidim.global_engine_path).to eq("/global_engine")
  end

  context "with an explicit mount route" do
    let(:mount_at) { "/foo" }

    it "mounts the engine under the right route" do
      expect(decidim.global_engine_path).to eq("/foo")
    end

    it "renders the engine" do
      visit decidim.global_engine_path
      expect(page).to have_content("DUMMY ENGINE")
    end
  end
end
