# frozen_string_literal: true

shared_examples "order" do |options|
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

    if options == :total_budget
      context "when total budgets is activated" do
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
    end

    if options == :total_projects
      context "when total project is activated" do
        let(:total_projects_component) { create(:budget_component, :with_vote_per_project) }
        let(:order) { create :order, component: total_projects_component }

        it "can't exceed a maximum order number" do
          project1 = create(:project, component: subject.component, budget: 100)
          project2 = create(:project, component: subject.component, budget: 20)

          subject.projects << project1
          subject.projects << project2

          subject.component.settings = {
            "total_projects" => 1, "vote_per_project" => true
          }

          expect(subject).to be_invalid
        end

        it "can't be lower than a minimum order number when checked out" do
          project1 = create(:project, component: subject.component, budget: 20)

          subject.projects << project1

          subject.component.settings = {
            "total_projects" => 10, "vote_per_project" => true
          }

          expect(subject).to be_valid
          subject.checked_out_at = Time.current
          expect(subject).to be_invalid
        end

        it "can exceed a maximum order value" do
          project1 = create(:project, component: subject.component, budget: 99_999)
          project2 = create(:project, component: subject.component, budget: 99_999)

          subject.projects << project1
          subject.projects << project2

          subject.component.settings = {
            "total_projects" => 2, "vote_per_project" => true
          }

          expect(subject).to be_valid
        end

        it "can be lower than a minimum order value when checked out" do
          project1 = create(:project, component: subject.component, budget: 0)

          subject.projects << project1

          subject.component.settings = {
            "total_projects" => 1, "vote_per_project" => true
          }

          subject.checked_out_at = Time.current
          expect(subject).to be_valid
        end
      end
    end
  end

  if options == :total_budget
    describe "#total_budget" do
      let(:total_budget_component) { create :order, component: create(:budget_component) }

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
  if options == :total_projects
    describe "#total_budget" do
      let(:total_projects_component) { create(:budget_component, :with_vote_per_project) }

      it "returns the sum of project budgets" do
        subject.projects << build(:project, component: subject.component)

        expect(subject.total_projects).to eq(subject.projects.count(&:budget))
      end
    end

    describe "#checked_out?" do
      let(:total_projects_component) { create(:budget_component, :with_vote_per_project) }

      it "returns true if the checked_out_at attribute is present" do
        subject.checked_out_at = Time.zone.now
        expect(subject).to be_checked_out
      end
    end
  end
end
