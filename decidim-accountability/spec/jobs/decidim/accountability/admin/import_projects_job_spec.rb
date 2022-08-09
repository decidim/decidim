# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::ImportProjectsJob do
  subject { described_class }

  let(:user) { create :user, organization: }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }

  let(:current_component) { create(:component, manifest_name: "accountability", participatory_space:, published_at: accountability_component_published_at) }
  let(:accountability_component_published_at) { nil }

  let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space:) }
  let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
  let(:selected_at) { Time.current }

  let(:command) { described_class.new(form) }
  let(:proposal_component) do
    create(:component, manifest_name: "proposals", participatory_space:)
  end

  let(:proposals) do
    create_list(
      :proposal,
      3,
      component: proposal_component
    )
  end
  let(:form) do
    double(
      valid?: valid,
      current_component:,
      origin_component: budget_component,
      origin_component_id: budget_component.id,
      import_all_selected_projects: true,
      current_user: user
    )
  end
  let(:valid) { true }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "#perform" do
    let(:mailer) { double :mailer }
    let!(:projects) { create_list(:project, 3, budget:, selected_at: Time.current) }
    let(:projects_id) { projects.ids }
    let(:current_user) { user }

    it "imports the projects" do
      expect do
        subject.perform_now(projects, current_component, current_user)
      end.to change(Decidim::Accountability::Result, :count).from(0).to(3)
    end

    it "emails the user after importing" do
      allow(Decidim::Accountability::ImportProjectsMailer)
        .to receive(:import)
        .with(current_user)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_now)

      subject.perform_now(projects, current_component, current_user)
    end
  end
end
