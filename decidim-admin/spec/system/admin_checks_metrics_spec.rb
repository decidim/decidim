# frozen_string_literal: true

require "spec_helper"

describe "Admin checks metrics", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:metric_manifests) { Decidim.metrics_registry.filtered(scope: "home") }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    metric_manifests.each do |manifest|
      create :metric, organization: organization, metric_type: manifest.metric_name, day: Time.zone.today
      create :metric, organization:, metric_type: manifest.metric_name, day: Time.zone.yesterday
    end

    visit decidim_admin.root_path
  end

  it "lists metrics" do
    expect(page).to have_content("Metrics")
    expect(page).to have_selector(".areachart", count: 9)
  end

  it "allows checking more metrics" do
    click_link "See more metrics"

    expect(page).to have_content("Metrics")
    expect(page).to have_selector(".areachart", count: metric_manifests.count)
  end
end
