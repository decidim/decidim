# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  describe ".lazy_relation" do
    let(:organization) { create(:organization) }
    let(:component) { create(:component, :published, manifest_name: "accountability", organization:) }
    let!(:resources) { create_list(:result, 2, component:) }

    include_examples "action log lazy relation"
  end
end
