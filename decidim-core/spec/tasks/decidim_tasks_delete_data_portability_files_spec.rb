# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:delete_data_portability_files", type: :task do
  let!(:original_expiry_time) { Decidim.data_portability_expiry_time }
  let!(:user) { create(:user) }

  before do
    Decidim.data_portability_expiry_time = 0.seconds
  end

  after do
    Decidim.data_portability_expiry_time = original_expiry_time
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
      expect(portability_attachments.count).to be_positive
      expect { task.execute }.not_to raise_error
      expect(portability_attachments.count).to be_zero
    end
  end

  #-------------------------------------------------------------
  private

  #-------------------------------------------------------------

  def produce_data_portability_files
    user.data_portability_file.attach(io: File.open(Decidim::Dev.asset("city.jpeg")), filename: "city.jpeg")
  end

  def portability_attachments
    ActiveStorage::Attachment.joins(:blob).where(
      name: "data_portability_file",
      record_type: "Decidim::UserBaseEntity"
    )
  end
end
