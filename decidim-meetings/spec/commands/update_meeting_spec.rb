require "spec_helper"

describe Decidim::Meetings::Admin::UpdateMeeting do
  let(:meeting) { create :meeting}
  let(:organization) { meeting.feature.organization }
  let(:scope) { create :scope, organization: organization }
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
      decidim_scope_id: scope.id,
      address: "address"
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, meeting) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "creates the meeting" do
      expect { subject.call }.to change { Decidim::Meetings::Meeting.count }.by(1)
    end
  end
end
