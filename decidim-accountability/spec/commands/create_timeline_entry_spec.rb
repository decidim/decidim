# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::CreateTimelineEntry do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, manifest_name: "accountability", participatory_space: participatory_process }
  let(:result) { create :accountability_result, feature: current_feature }

  let(:date) { "2017-8-23" }
  let(:description) { "description" }

  let(:form) do
    double(
      :invalid? => invalid,
      decidim_accountability_result_id: result.id,
      entry_date: date,
      description: { en: description }
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
    let(:timeline_entry) { Decidim::Accountability::TimelineEntry.last }

    it "creates the timeline entry" do
      expect { subject.call }.to change { Decidim::Accountability::TimelineEntry.count }.by(1)
    end

    it "sets the entry date" do
      subject.call
      expect(timeline_entry.entry_date).to eq(Date.new(2017,8,23))
    end

    it "sets the description" do
      subject.call
      expect(translated timeline_entry.description).to eq description
    end

    it "sets the result" do
      subject.call
      expect(timeline_entry.result).to eq(result)
    end
  end
end
