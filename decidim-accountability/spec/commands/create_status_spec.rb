# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::CreateStatus do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, manifest_name: "accountability", participatory_space: participatory_process }

  let(:key) { "planned" }
  let(:name) { "Planned" }
  let(:description) { "description" }
  let(:progress) { 75 }

  let(:form) do
    double(
      invalid?: invalid,
      current_feature: current_feature,
      key: key,
      name: { en: name },
      description: { en: description },
      progress: progress
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
    let(:status) { Decidim::Accountability::Status.last }

    it "creates the status" do
      expect { subject.call }.to change { Decidim::Accountability::Status.count }.by(1)
    end

    it "sets the name" do
      subject.call
      expect(translated(status.name)).to eq name
    end

    it "sets the description" do
      subject.call
      expect(translated(status.description)).to eq description
    end

    it "sets the key" do
      subject.call
      expect(status.key).to eq key
    end

    it "sets the progress" do
      subject.call
      expect(status.progress).to eq progress
    end
  end
end
