# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::DiffChangesetCalculator do
  subject { described_class.new(changeset, fields_mapping).changeset }

  let(:date1) { 1.day.ago }
  let(:date2) { 1.hour.ago }
  let(:date3) { 1.day.from_now }
  let(:changeset) do
    {
      updated_at: [date1, date2],
      start_date: [date1, date3],
      title: ["Old title", "New title"]
    }
  end
  let(:fields_mapping) do
    {
      updated_at: :date,
      title: :string
    }
  end
  let(:title_attribute) do
    subject.find{ |field| field[:attribute_name] == :title }
  end

  describe "#changeset" do
    it "only keeps the fields in fields mapping" do
      attribute_names = subject.map{ |field| field[:attribute_name] }
      expect(attribute_names).to match_array([:updated_at, :title])
    end

    it "generates the correct structure for the fields" do
      expect(title_attribute.keys).to match_array([:attribute_name, :previous_value, :new_value, :type])
      expect(title_attribute[:attribute_name]).to eq :title
      expect(title_attribute[:previous_value]).to eq "Old title"
      expect(title_attribute[:new_value]).to eq "New title"
      expect(title_attribute[:type]).to eq :string
    end
  end
end