# frozen_string_literal: true

require "spec_helper"

shared_examples "an order" do |*options|
  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end

    it "is invalid when user is not present" do
      subject.user = nil
      expect(subject).to be_invalid
    end

    it "is invalid when budget is not present" do
      subject.budget = nil
      expect(subject).to be_invalid
    end

    it "is unique for each user and component" do
      subject.save
      new_order = build :order, user: subject.user, budget: budget
      expect(new_order).to be_invalid
    end

    if options.include?(:with_maximum_budget)
      it "can't exceed a maximum order value" do
        project1 = create(:project, budget:, budget_amount: 100)
        project2 = create(:project, budget:, budget_amount: 20)

        subject.projects << project1
        subject.projects << project2

        subject.component.settings = {
          "vote_threshold" => 50
        }
        budget.update!(total_budget: 100)

        expect(subject).to be_invalid
      end
    end
  end

  describe "#total_budget" do
    it "returns the sum of project budgets" do
      subject.projects << build(:project, budget: subject.budget)

      expect(subject.total_budget).to eq(subject.projects.sum(&:budget_amount))
    end
  end

  describe "#total_projects" do
    it "returns the count of projects" do
      subject.projects << build(:project, budget: subject.budget)

      expect(subject.total_projects).to eq(subject.projects.size)
    end
  end

  describe "#checked_out?" do
    it "returns true if the checked_out_at attribute is present" do
      subject.checked_out_at = Time.current
      expect(subject).to be_checked_out
    end
  end
end

module Decidim::Budgets
  describe Order do
    subject { order }

    let(:component) { create :budgets_component, voting_rule }
    let(:budget) { create(:budget, component:, total_budget:) }
    let(:order) { create :order, budget: }
    let(:voting_rule) { :with_vote_threshold_percent }
    let(:total_budget) { 100_000 }

    describe "with component with a vote threshold percent rule" do
      let(:total_budget) { 100 }
      let!(:order) { create :order, budget: }

      it_behaves_like "an order", :with_maximum_budget

      it "can't be lower than a minimum order value when checked out" do
        project1 = create(:project, budget:, budget_amount: 20)

        subject.projects << project1

        subject.component.settings = { "vote_threshold" => 50 }

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_invalid
      end
    end

    describe "with component with a minimum projects rule" do
      let!(:order) { create :order, budget: }
      let(:voting_rule) { :with_minimum_budget_projects }

      it_behaves_like "an order", :with_maximum_budget

      it "can't be lower than a minimum projects number when checked out" do
        project1 = create(:project, budget:, budget_amount: 100)

        subject.projects << project1

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_invalid
      end

      it "has to reach the minimum projects number when checked out" do
        projects = create_list(:project, 3, budget:, budget_amount: 100)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_valid
      end
    end

    describe "with component with a maximum projects rule" do
      let(:component) do
        create(
          :budgets_component,
          voting_rule,
          vote_minimum_budget_projects_number:,
          vote_maximum_budget_projects_number:
        )
      end
      let!(:order) { create :order, budget: }
      let(:voting_rule) { :with_budget_projects_range }
      let(:vote_minimum_budget_projects_number) { 0 }
      let(:vote_maximum_budget_projects_number) { 6 }

      it_behaves_like "an order"

      it "can't be higher than a maximum projects number when checked out" do
        projects = create_list(:project, 7, budget:, budget_amount: 100)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_invalid
      end

      it "has to be under the maximum projects number when checked out" do
        projects = create_list(:project, 6, budget:, budget_amount: 100)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_valid
      end

      it "can exceed the maximum budget when checked out" do
        projects = create_list(:project, 6, budget:, budget_amount: 100_000_000)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_valid
      end
    end

    describe "with component with a minimum and maximum projects rule" do
      let(:component) do
        create(
          :budgets_component,
          voting_rule,
          vote_minimum_budget_projects_number:,
          vote_maximum_budget_projects_number:
        )
      end
      let!(:order) { create :order, budget: }
      let(:voting_rule) { :with_budget_projects_range }
      let(:vote_minimum_budget_projects_number) { 3 }
      let(:vote_maximum_budget_projects_number) { 6 }

      it_behaves_like "an order"

      it "can't be higher than a maximum projects number when checked out" do
        projects = create_list(:project, 7, budget:, budget_amount: 100)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_invalid
      end

      it "can't be lower than a minimum projects number when checked out" do
        project1 = create(:project, budget: subject.budget, budget_amount: 100)

        subject.projects << project1

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_invalid
      end

      it "has to reach the minimum projects number when checked out" do
        projects = create_list(:project, 4, budget:, budget_amount: 100)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_valid
      end

      it "has to be under the maximum projects number when checked out" do
        projects = create_list(:project, 6, budget:, budget_amount: 100)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_valid
      end

      it "can exceed the maximum budget when checked out" do
        projects = create_list(:project, 6, budget:, budget_amount: 100_000_000)

        subject.projects << projects

        expect(subject).to be_valid
        subject.checked_out_at = Time.current
        expect(subject).to be_valid
      end
    end
  end
end
