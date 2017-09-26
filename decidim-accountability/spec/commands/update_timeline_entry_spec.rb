# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::UpdateTimelineEntry do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, manifest_name: "accountability", participatory_space: participatory_process }
  let(:result) { create :accountability_result, feature: current_feature }

  let(:timeline_entry) { create :accountability_timeline_entry, result: result }

  let(:date) { "2017-9-23" }
  let(:description) { "new description" }

  let(:form) do
    double(
      :invalid? => invalid,
      entry_date: date,
      description: { en: description }
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, timeline_entry) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "sets the date" do
      subject.call
      expect(timeline_entry.entry_date).to eq(Date.new(2017,9,23))
    end

    it "sets the description" do
      subject.call
      expect(translated timeline_entry.description).to eq description
    end
  end
end
