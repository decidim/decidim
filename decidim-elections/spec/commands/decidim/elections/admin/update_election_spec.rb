# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::UpdateElection do
  subject { described_class.new(form, election) }

  let(:election) { create :election }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      title: { en: "title" },
      description: { en: "description" },
      start_time:,
      end_time:,
      attachment: attachment_params,
      photos: current_photos,
      add_photos: uploaded_photos
    )
  end
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 2.days.from_now }
  let(:current_photos) { [] }
  let(:uploaded_photos) { [] }
  let(:attachment_params) { nil }
  let(:invalid) { false }

  it "updates the election" do
    subject.call
    expect(translated(election.title)).to eq "title"
    expect(translated(election.description)).to eq "description"
    expect(election.start_time).to be_within(1.second).of start_time
    expect(election.end_time).to be_within(1.second).of end_time
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:update!)
      .with(election, user, hash_including(:title, :description, :start_time, :end_time), visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
  end

  context "with attachment" do
    it_behaves_like "admin manages resource gallery" do
      let(:command) { described_class.new(form, election) }
      let(:resource_class) { Decidim::Elections::Election }
      let(:resource) { election }
    end
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
