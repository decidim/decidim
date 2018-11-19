# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Metrics::CommentParticipantsMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_space) }
  let(:commentable) { create(:dummy_resource, component: component) }
  let!(:comments) { create_list(:comment, 2, root_commentable: commentable, commentable: commentable, created_at: day) }
  let!(:old_comments) { create_list(:comment, 2, root_commentable: commentable, commentable: commentable, created_at: day - 1.week) }
  # TOTAL Participants for Comments:
  #  Cumulative: 4
  #  Quantity: 2

  context "when executing class" do
    it "fails to create object with an invalid resource" do
      manager = described_class.new(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.new(day, participatory_space).calculate

      expect(result[:cumulative_users].count).to eq(4)
      expect(result[:quantity_users].count).to eq(2)
    end

    it "does not found any result for past days" do
      result = described_class.new(day - 1.month, participatory_space).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
