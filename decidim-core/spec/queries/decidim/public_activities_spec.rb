# frozen_string_literal: true

require "spec_helper"

describe Decidim::PublicActivities do
  let(:organization) { create(:organization) }
  let(:options) { {} }

  describe "#query" do
    subject { described_class.new(organization, options).query }

    let(:user) { create(:user, organization:) }
    let(:component) { create(:dummy_component, organization:) }
    let(:resources) { create_list(:dummy_resource, 5, component:) }

    let!(:visible_logs) do
      [].tap do |logs|
        logs << create(:action_log, action: "update", visibility: "public-only", resource: resources[0], organization:, participatory_space: component.participatory_space, user:)
        logs << create(:action_log, action: "create", visibility: "all", resource: resources[1], organization:, participatory_space: component.participatory_space, user:)
      end.reverse
    end
    let!(:private_logs) do
      [].tap do |logs|
        logs << create(:action_log, action: "create", visibility: "private-only", resource: resources[2], organization:, participatory_space: component.participatory_space, user:)
      end.reverse
    end

    context "with follows" do
      let(:options) { { follows: Decidim::Follow.where(user:) } }
      let!(:follows) { resources.map { |f| create(:follow, followable: f, user:) } }

      it "returns the correct logs" do
        expect(subject).to eq(visible_logs)
      end
    end
  end
end
