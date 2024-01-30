# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataJob do
  subject { described_class }

  let(:organization) { create(:organization) }

  describe "perform" do
    before do
      organization.open_data_file.purge
    end

    it "uploads the generated file" do
      expect { subject.perform_now(organization) }.to change { organization.open_data_file.attached? }.from(false).to(true)
    end
  end

  it "deletes the temporary file after finishing the job" do
    organization = create(:organization)

    expect(File).to receive(:delete) do |path|
      expect(path.to_s).to match(%r{tmp/.*})
    end
    described_class.perform_now(organization)
  end
end
