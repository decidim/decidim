# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Order do
  let!(:order) { create :order, feature: create(:budget_feature) }
  subject { order }

  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end

    it "is invalid when user is not present" do
      subject.user = nil
      expect(subject).to be_invalid
    end

    it "is invalid when feature is not present" do
      subject.feature = nil
      expect(subject).to be_invalid
    end

    it "is unique for each user and feature" do
      subject.save
      new_order = build :order, user: subject.user, feature: subject.feature
      expect(new_order).to be_invalid
    end

    it "can't exceed a maximum order value" do
      project1 = create(:project, feature: subject.feature, budget: 100)
      project2 = create(:project, feature: subject.feature, budget: 20)

      subject.projects << project1
      subject.projects << project2

      subject.feature.settings = {
        "total_budget" => 100, "vote_threshold" => 50
      }

      expect(subject).to be_invalid
    end

    it "can't be lower than a minimum order value when checked out" do
      project1 = create(:project, feature: subject.feature, budget: 20)

      subject.projects << project1

      subject.feature.settings = {
        "total_budget" => 100, "vote_threshold" => 50
      }

      expect(subject).to be_valid
      subject.checked_out_at = Time.current
      expect(subject).to be_invalid
    end
  end

  describe "#total_budget" do
    it "returns the sum of project budgets" do
      subject.projects << build(:project, feature: subject.feature)

      expect(subject.total_budget).to eq(subject.projects.sum(&:budget))
      expect(subject)
    end
  end

  describe "#checked_out?" do
    it "returns true if the checked_out_at attribute is present" do
      subject.checked_out_at = Time.zone.now
      expect(subject).to be_checked_out
    end
  end
end
