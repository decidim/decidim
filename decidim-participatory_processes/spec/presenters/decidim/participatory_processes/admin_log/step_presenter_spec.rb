# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::AdminLog::StepPresenter, type: :helper do
  subject { presenter.present }

  let(:presenter) { described_class.new(action_log, helper) }
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:step) { create(:participatory_process_step, participatory_process:, title: { en: "Current phase" }) }
  let(:action) { "system_activate" }
  let(:user) { nil }
  let(:action_log) do
    create(
      :action_log,
      user:,
      action:,
      resource: step,
      participatory_space: participatory_process,
      organization:
    )
  end

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  context "when the action is performed by the system" do
    it "renders the system activation message without an author" do
      expect(subject).to include("Current phase")
      expect(subject).to include("phase was automatically activated")
      expect(subject).not_to include("logs__log__author")
    end
  end

  context "when the user who performed the action no longer exists" do
    let(:action) { "activate" }
    let(:user) { create(:user, organization:, name: "Deleted Author") }

    before do
      user.destroy!
      action_log.reload
    end

    it "renders the saved author name without a profile link" do
      expect(action_log.user).to be_nil
      expect(subject).to include("Deleted Author")
      expect(subject).not_to include("href=\"/en/profiles/")
    end
  end
end
