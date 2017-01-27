require "spec_helper"

describe Decidim::Meetings::Admin::UpdateMeeting do
  let(:meeting) { create(:meeting) }
  let(:organization) { meeting.feature.organization }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: meeting.feature.participatory_process }
  let(:address) { meeting.address }
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
      scope: scope,
      category: category,
      address: address
    )
  end
  let(:invalid) { false }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(address, [
      { 'latitude' => latitude, 'longitude' => longitude }
    ])
  end

  subject { described_class.new(form, meeting) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "updates the meeting" do
      subject.call
      expect(translated(meeting.title)).to eq "title"
    end

    it "sets the scope" do
      subject.call
      expect(meeting.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(meeting.category).to eq category
    end

    context "when the address has not changed" do
      it "doesn't geocode the meeting" do
        expect(meeting).not_to receive(:geocode)
        subject.call
      end
    end

    context "when the address has changed" do
      let(:address) { "New address" }

      it "geocodes the meeting" do
        expect(meeting).to receive(:geocode)
        subject.call
      end
    end
  end
end
