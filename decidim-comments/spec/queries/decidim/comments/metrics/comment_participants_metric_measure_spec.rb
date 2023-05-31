# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Metrics::CommentParticipantsMetricMeasure do
  let(:day) { Time.zone.yesterday }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:other_participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:component, participatory_space:) }
  let(:commentable) { create(:dummy_resource, component:) }
  let!(:comments) { create_list(:comment, 2, root_commentable: commentable, commentable:, created_at: day) }
  let!(:old_comments) { create_list(:comment, 2, root_commentable: commentable, commentable:, created_at: day - 1.week) }
  let(:other_component) { create(:component, participatory_space: other_participatory_space) }
  let(:other_commentable) { create(:dummy_resource, component: other_component) }
  let!(:other_comments) { create_list(:comment, 2, root_commentable: other_commentable, commentable: other_commentable, created_at: day) }
  # TOTAL Participants for Comments: (Other ParticipatorySpace's related records not counted)
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
