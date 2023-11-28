# frozen_string_literal: true

require "spec_helper"

describe "Admin reports user" do
  before do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end
  it_behaves_like "hideable resource during block" do
    let(:reportable) { content.author }

    let(:component) { create(:meeting_component, organization:) }
    let(:content) { create(:meeting, :participant_author, :published, component:) }
  end
end
