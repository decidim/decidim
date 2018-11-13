# frozen_string_literal: true

require "spec_helper"

describe Decidim::PublicComponents do
  subject { described_class.new(organization) }

  let(:process) { create :participatory_process }
  let(:organization) { process.organization }
  let!(:component) { create :component, :unpublished, participatory_space: process }
  let!(:published_component) { create :component, :published, participatory_space: process }
  let!(:published_component2) { create :component, :published, participatory_space: process, manifest_name: "foo" }
  let!(:another_component) { create :component }

  it "finds the public and published components" do
    expect(subject.query).to match [published_component, published_component2]
  end

  context "when filtering by manifest_name" do
    subject { described_class.new(organization, manifest_name: "foo") }

    it "filters by manifest_type" do
      expect(subject.query).to match [published_component2]
    end
  end
end
