require "spec_helper"

describe Decidim::Results::Admin::CreateResult do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_process: participatory_process }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:form) do
    double(
      :invalid? => invalid,
      title: {en: "title"},
      description: {en: "description"},
      short_description: {en: "short_description"},
      scope: scope,
      category: category,
      current_feature: current_feature
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
    let(:meeting) { Decidim::Results::Result.last }

    it "creates the meeting" do
      expect { subject.call }.to change { Decidim::Results::Result.count }.by(1)
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
  end
end
