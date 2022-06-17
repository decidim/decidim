# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::DestroyElection do
  subject { described_class.new(election, user) }

  let!(:election) { create :election }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: }

  it "destroys the election" do
    expect { subject.call }.to change { Decidim::Elections::Election.count }.by(-1)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:delete, election, user, visibility: "all")
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

  context "with attachments" do
    let(:command) { described_class.new(election, user) }
    let!(:image) { create(:attachment, :with_image, attached_to: election) }

    it_behaves_like "admin destroys resource gallery" do
      let(:resource) { election }
    end
  end
end
