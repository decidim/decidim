# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::CreateElection do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      subtitle: { en: "subtitle" },
      description: { en: "description" },
      start_time: start_time,
      end_time: end_time,
      current_user: user,
      current_component: current_component,
      current_organization: organization
    )
  end
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 2.days.from_now }
  let(:invalid) { false }

  let(:election) { Decidim::Elections::Election.last }

  it "creates the election" do
    expect { subject.call }.to change { Decidim::Elections::Election.count }.by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(election.title)).to eq "title"
    expect(translated(election.subtitle)).to eq "subtitle"
    expect(translated(election.description)).to eq "description"
    expect(election.start_time).to eq start_time
    expect(election.end_time).to eq end_time
  end

  it "sets the component" do
    subject.call
    expect(election.component).to eq current_component
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Elections::Election,
        user,
        hash_including(:title, :subtitle, :description, :end_time, :start_time, :component),
        visibility: "all"
      )
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "create"
  end

  describe "events" do
    let(:space_follower) { create(:user, organization: organization) }
    let!(:space_follow) { create :follow, followable: participatory_process, user: space_follower }

    it "notifies the change to the participatory space followers" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.elections.election_created",
          event_class: Decidim::Elections::CreateElectionEvent,
          resource: kind_of(Decidim::Elections::Election),
          followers: [space_follower]
        )

      subject.call
    end
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
