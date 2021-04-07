# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_votings_census:delete_census_access_codes_export", type: :task do
  let!(:original_expiry_time) { Decidim::Votings::Census.census_access_codes_export_expiry_time }
  let!(:original_base_uploads_path) { Decidim.base_uploads_path }

  let(:uploader) { Decidim::Votings::Census::VotingCensusUploader.new }
  let(:files_expression) { "#{uploader.store_dir}/*" }

  before do
    Decidim::Votings::Census.census_access_codes_export_expiry_time = 0.seconds
    Decidim.base_uploads_path = Rails.root.join("tmp/storage/census")
  end

  after do
    Decidim::Votings::Census.census_access_codes_export_expiry_time = original_expiry_time
    uploader.remove!
    Decidim.base_uploads_path = original_base_uploads_path
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
      expect { task.execute }.not_to raise_error
      check_census_dir_empty
    end
  end

  private

  def generate_file
    uploader.store!(Tempfile.new("temp_file"))
  end

  def check_census_dir_empty
    expect(Dir[files_expression].empty?).to be true
  end
end
