# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_votings_census:delete_census_access_codes_export", type: :task do
  let!(:original_expiry_time) { Decidim::Votings::Census.census_access_codes_export_expiry_time }
  let!(:dataset) { create(:dataset) }

  before do
    Decidim::Votings::Census.census_access_codes_export_expiry_time = 0.seconds
  end

  after do
    Decidim::Votings::Census.census_access_codes_export_expiry_time = original_expiry_time
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when there are no files" do
    it "does nothing" do
      expect { task.execute }.not_to raise_error
    end
  end

  context "when there are some files" do
    before do
      generate_file
    end

    it "runs gracefully" do
      expect(census_attachments.count).to be_positive
      expect { task.execute }.not_to raise_error
      expect(census_attachments.count).to be_zero
    end
  end

  private

  def generate_file
    dataset.access_codes_file.attach(io: File.open(Decidim::Dev.asset("city.jpeg")), filename: "city.jpeg")
  end

  def census_attachments
    ActiveStorage::Attachment.joins(:blob).where(
      name: "access_codes_file",
      record_type: "Decidim::Votings::Census::Dataset"
    )
  end
end
