# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Metrics::DebateParticipantsMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }

  # Create a debate (Debates)
  let(:debates_component) { create(:debates_component, :published, participatory_space: participatory_space) }
  let(:debates) { create_list(:debate, 5, :with_author, component: debates_component, created_at: day) }
  # TOTAL Participants for Debates: 5
  let(:all) { debates }

  context "when executing class" do
    before { all }

    it "fails to create object with an invalid resource" do
      manager = described_class.for(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.for(day, debates_component).calculate

      expect(result[:cumulative_users].count).to eq(5)
      expect(result[:quantity_users].count).to eq(5)
    end

    it "does not found any result for past days" do
      result = described_class.for(day - 1.month, debates_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
