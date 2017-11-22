# frozen_string_literal: true

require "spec_helper"

describe "Feature routing", type: :routing do
  routes { Decidim::Core::Engine.routes }

  let(:participatory_process) { create(:participatory_process) }

  let(:target_route) { "/processes/#{participatory_process.id}/f/99999999" }

  it "does not specifically route to error controller on missing features" do
    expect(get: target_route).not_to be_routable
  end
end
