# frozen_string_literal: true

require "spec_helper"
require "support/tasks"
require "tasks/decidim_tasks_sniffs_stdout_context"

describe "rake decidim:delete_data_portability_files", type: :task do
  let!(:original_expiry_time) { Decidim.data_portability_expiry_time }

  let(:uploader) { ::Decidim::DataPortabilityUploader.new }
  let(:files_expression) { "#{uploader.store_dir}/*" }

  before do
    Decidim.data_portability_expiry_time = 0.seconds
  end

  after do
    Decidim.data_portability_expiry_time = original_expiry_time
    uploader.remove!
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
      produce_data_portability_files
    end

    it "runs gracefully" do
      expect { task.execute }.not_to raise_error
      check_no_data_portability_files_remain
    end
  end

  #-------------------------------------------------------------
  private

  #-------------------------------------------------------------

  def produce_data_portability_files
    Decidim.base_uploads_path = Rails.root.join("tmp", "storage", "data_portability")
    uploader.store!(Tempfile.new("produce_data_portability_files"))
  end

  def check_no_data_portability_files_remain
    expect(Dir[files_expression].empty?).to be true
  end
end
