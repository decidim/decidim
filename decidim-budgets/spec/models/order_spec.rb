# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Order do
    subject { order }

    let!(:order) { create :order, component: create(:budget_component) }

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "is invalid when user is not present" do
        subject.user = nil
        expect(subject).to be_invalid
      end

      it "is invalid when component is not present" do
        subject.component = nil
        expect(subject).to be_invalid
      end

      it "is unique for each user and component" do
        subject.save
        new_order = build :order, user: subject.user, component: subject.component
        expect(new_order).to be_invalid
      end

      it "can't exceed a maximum order value" do
        project1 = create(:project, component: subject.component, budget: 100)
        project2 = create(:project, component: subject.component, budget: 20)

        subject.projects << project1
        subject.projects << project2

        subject.component.settings = {
          "total_budget" => 100, "vote_threshold" => 50
        }

        expect(subject).to be_invalid
      end

      it "can't be lower than a minimum order value when checked out" do
        project1 = create(:project, component: subject.component, budget: 20)

        subject.projects << project1

        subject.component.settings = {
          "total_budget" => 100, "vote_threshold" => 50
        }

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_invalid
      end
    end

    describe "#total_budget" do
      it "returns the sum of project budgets" do
        subject.projects << build(:project, component: subject.component)

        expect(subject.total_budget).to eq(subject.projects.sum(&:budget))
      end
    end

    describe "#checked_out?" do
      it "returns true if the checked_out_at attribute is present" do
        subject.checked_out_at = Time.zone.now
        expect(subject).to be_checked_out
      end
    end
  end
end
