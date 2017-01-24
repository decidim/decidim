require "spec_helper"

describe Decidim::Meetings::Admin::CreateMeeting do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_process: participatory_process }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:address) { "address" }
  let(:form) do
    double(
      :invalid? => invalid,
      title: {en: "title"},
      description: {en: "description"},
      short_description: {en: "short_description"},
      location: {en: "location"},
      location_hints: {en: "location_hints"},
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 1.hour,
      address: address,
      scope: scope,
      category: category,
      current_feature: current_feature
    )
  end
  let(:invalid) { false }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder.configure(:lookup => :test)

    Geocoder::Lookup::Test.add_stub(address, [
      { 'latitude' => latitude, 'longitude' => longitude }
    ])
  end

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:meeting) { Decidim::Meetings::Meeting.last }

    it "creates the meeting" do
      expect { subject.call }.to change { Decidim::Meetings::Meeting.count }.by(1)
    end

    it "sets the scope" do
      subject.call
      expect(meeting.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(meeting.category).to eq category
    end

    it "sets the feature" do
      subject.call
      expect(meeting.feature).to eq current_feature
    end

    it "geocodes the meeting" do
      subject.call
      last_meeting = Decidim::Meetings::Meeting.last
      expect(last_meeting.latitude).to eq(latitude)
      expect(last_meeting.longitude).to eq(longitude)
    end
  end
end
