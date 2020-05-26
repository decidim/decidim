# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::UpdateElection do
  subject { described_class.new(form, election) }

  let(:election) { create :election }
  let(:organization) { election.component.organization }
  let(:category) { create :category, participatory_space: election.component.participatory_space }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      title: { en: "title" },
      subtitle: { en: "subtitle" },
      description: { en: "description" },
      start_time: start_time,
      end_time: end_time
    )
  end
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 2.days.from_now }
  let(:invalid) { false }

  it "updates the election" do
    subject.call
    expect(translated(election.title)).to eq "title"
    expect(translated(election.subtitle)).to eq "subtitle"
    expect(translated(election.description)).to eq "description"
    expect(election.start_time).to eq start_time
    expect(election.end_time).to eq end_time
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:update!)
      .with(election, user, hash_including(:title, :subtitle, :description, :start_time, :end_time), visibility: "all")
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
