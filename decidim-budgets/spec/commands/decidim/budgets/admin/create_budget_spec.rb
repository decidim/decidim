# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::CreateBudget do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "budgets" }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:scope) { create :scope, organization: organization }

  let(:form) do
    double(
      invalid?: invalid,
      weight: 0,
      title: { en: "title" },
      description: { en: "description" },
      total_budget: 100_000_000,
      scope: scope,
      current_user: user,
      current_component: current_component,
      current_organization: organization
    )
  end

  let(:invalid) { false }

  let(:budget) { Decidim::Budgets::Budget.last }

  it "creates the budget" do
    expect { subject.call }.to change(Decidim::Budgets::Budget, :count).by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(budget.title)).to eq "title"
    expect(translated(budget.description)).to eq "description"
    expect(budget.weight).to eq 0
    expect(budget.total_budget).to eq 100_000_000
    expect(budget.scope).to eq scope
  end

  it "sets the component" do
    subject.call
    expect(budget.component).to eq current_component
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Budgets::Budget,
        user,
        hash_including(:title, :description, :component, :weight, :total_budget),
        visibility: "all"
      )
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "create"
  end

  it "creates a searchable resource" do
    expect { subject.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
