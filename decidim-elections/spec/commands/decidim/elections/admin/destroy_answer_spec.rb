# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::DestroyAnswer do
  subject(:command) { described_class.new(answer, user) }

  let(:election) { create :election }
  let(:question) { create :question, election: election }
  let!(:answer) { create :election_answer, question: question }
  let(:component) { election.component }
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  it "destroys the answer" do
    expect { subject.call }.to change(Decidim::Elections::Answer, :count).by(-1)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:delete, answer, user, visibility: "all")
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
    let!(:image) { create(:attachment, :with_image, attached_to: answer) }

    it_behaves_like "admin destroys resource gallery" do
      let(:resource) { answer }
    end
  end
end
