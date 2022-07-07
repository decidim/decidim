# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::DestroyBudget do
  subject { described_class.new(budget, user) }

  let!(:budget) { create :budget }
  let(:organization) { budget.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  it "destroys the budget" do
    expect { subject.call }.to change(Decidim::Budgets::Budget, :count).by(-1)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:delete, budget, user, visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "destroy"
  end

  context "when the budget has projects" do
    let!(:project) { create :project, budget: budget }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
