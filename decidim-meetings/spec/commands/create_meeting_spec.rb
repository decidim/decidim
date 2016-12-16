require "spec_helper"

describe Decidim::Meetings::Admin::CreateMeeting do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_process: participatory_process }
  let(:current_user) { create :user, organization: organization }
  let(:form) do
    double(
      :invalid? => invalid,
      title: {en: "title"},
      description: {en: "description"},
      short_description: {en: "short_description"},
      location: {en: "location"},
      location_hints: {en: "location_hints"},
      start_date: 1.day.from_now,
      end_date: 1.day.from_now + 1.hour,
      address: "address",
      current_feature: current_feature,
      current_user: current_user
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form) }

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
