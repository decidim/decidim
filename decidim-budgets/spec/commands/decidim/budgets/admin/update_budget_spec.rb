# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::UpdateBudget do
  subject { described_class.new(form, budget) }

  let(:budget) { create :budget }
  let(:organization) { budget.component.organization }
  let(:scope) { create :scope, organization: }
  let(:user) { create :user, :admin, :confirmed, organization: }
  let(:form) do
    double(
      invalid?: invalid,
      weight: 1,
      title: { en: "title" },
      description: { en: "description" },
      total_budget: 101_000_000,
      scope:,
      current_user: user
    )
  end

  let(:invalid) { false }

  it "updates the budget" do
    subject.call
    expect(translated(budget.title)).to eq "title"
    expect(translated(budget.description)).to eq "description"
    expect(budget.weight).to eq 1
    expect(budget.total_budget).to eq 101_000_000
    expect(budget.scope).to eq scope
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:update!)
      .with(budget, user, hash_including(:title, :description, :weight, :total_budget, :scope), visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
