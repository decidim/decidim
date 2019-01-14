# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataJob do
  subject { described_class }

  let(:organization) { create(:organization) }

  describe "perform" do
    before do
      FileUtils.rm(organization.open_data_file.file.path) if organization.open_data_file.file.exists?
    end

    it "uploads the generated file" do
      subject.perform_now(organization)

      expect(organization.open_data_file.file.exists?).to eq(true)
    end
  end
end
