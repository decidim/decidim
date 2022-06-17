# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::DestroyQuestion do
  subject { described_class.new(question, user) }

  let(:election) { create :election }
  let!(:question) { create :question, election: }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: }

  it "destroys the question" do
    expect { subject.call }.to change { Decidim::Elections::Question.count }.by(-1)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:delete, question, user, visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "destroy"
  end

  context "when the election has started" do
    let(:election) { create :election, :started }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
