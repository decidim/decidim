# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Engine do
  it_behaves_like "clean engine"

  it "creates the quality indicators page" do
    organization = create(:organization)

    expect do
      ActiveSupport::Notifications.publish("decidim.system.create_organization:after", { organization: })
    end.to change { organization.static_pages.count }.by(1)
  end
end
