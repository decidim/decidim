# frozen_string_literal: true

require "spec_helper"

describe Decidim::Commands::DestroyResource do
  subject { described_class.new(project, user) }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization:) }
  let(:budget) { create(:budget, component:) }
  let(:project) { create(:project, budget:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  context "when everything is ok" do
    it "destroys the project" do
      subject.call
      expect { project.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          :delete,
          project,
          user
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
