# frozen_string_literal: true

shared_examples "project" do |options|
  subject { project }

  let(:project) { create :project }

  include_examples "has reference"

  it { is_expected.to be_valid }
  it { is_expected.to be_versioned }

  context "without a component" do
    let(:project) { build :project, component: nil }

    it { is_expected.not_to be_valid }
  end

  context "when the scope is from another organization" do
    let(:scope) { create :scope }
    let(:project) { build :project, scope: scope }

    it { is_expected.not_to be_valid }
  end

  context "when the category is from another organization" do
    let(:category) { create :category }
    let(:project) { build :project, category: category }

    it { is_expected.not_to be_valid }
  end

  describe "#orders_count" do
    if options == :total_budget
      context "when total budget is activated" do
        let(:project) { create :project, budget: 75_000_000 }
        let(:order) { create :order, component: project.component }
        let(:unfinished_order) { create :order, component: project.component }
        let!(:line_item) { create :line_item, project: project, order: order }
        let!(:line_item_1) { create :line_item, project: project, order: unfinished_order }

        it "return number of finished orders for this project" do
          order.reload.update!(checked_out_at: Time.current)
          expect(project.confirmed_orders_count).to eq(1)
        end
      end
    end

    if options == :total_budget
      context "when total projects is activated" do
        let(:component) do
          create(
            :budget_component,
            :with_vote_per_project,
            total_projects: 1
          )
        end

        let(:project) { create :project, component: component }
        let(:order) { create :order, component: project.component }
        let(:unfinished_order) { create :order, component: project.component }
        let!(:line_item) { create :line_item, project: project, order: order }
        let!(:line_item_1) { create :line_item, project: project, order: unfinished_order }

        it "return number of finished orders for this project" do
          order.reload.update!(checked_out_at: Time.current)

          expect(project.confirmed_orders_count).to eq(1)
        end
      end
    end
  end

  describe "#users_to_notify_on_comment_created" do
    let(:admins) { subject.component.organization.admins }
    let(:users_with_role) { subject.component.organization.users_with_any_role }

    let(:participatory_process) { subject.component.participatory_space }
    let(:process_users_with_role) { Decidim::ParticipatoryProcessUserRole.where(decidim_participatory_process_id: participatory_process.id).map(&:user) }
    let(:users) do
      users = admins + users_with_role + process_users_with_role
      users.uniq
    end

    it "returns the followers" do
      expect(subject.users_to_notify_on_comment_created).to match_array(users)
    end
  end
end
