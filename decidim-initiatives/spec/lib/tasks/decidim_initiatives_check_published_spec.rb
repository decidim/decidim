# frozen_string_literal: true

require "spec_helper"

describe "decidim_initiatives:check_published", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when initiatives with enough votes" do
    let(:initiative) { create(:initiative, :acceptable) }

    it "is marked as accepted" do
      expect(initiative).to be_published

      task.execute
      initiative.reload
      expect(initiative).to be_accepted
    end
  end

  context "when initiatives without enough votes" do
    let(:initiative) { create(:initiative, :rejectable) }

    it "is marked as rejected" do
      expect(initiative).to be_published

      task.execute
      initiative.reload
      expect(initiative).to be_rejected
    end
  end

  context "when initiatives with presential support enabled" do
    let(:initiative) { create(:initiative, :acceptable, signature_type: "offline") }

    it "keeps unchanged" do
      expect(initiative).to be_published

      task.execute
      initiative.reload
      expect(initiative).to be_published
    end
  end

  context "when initiatives with mixed support enabled" do
    let(:initiative) { create(:initiative, :acceptable, signature_type: "any") }

    it "keeps unchanged" do
      expect(initiative).to be_published

      task.execute
      initiative.reload
      expect(initiative).to be_published
    end
  end
end
