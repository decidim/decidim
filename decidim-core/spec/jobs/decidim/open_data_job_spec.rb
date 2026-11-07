# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataJob do
  subject { described_class }

  let(:organization) { create(:organization) }

  describe "perform" do
    before do
      organization.open_data_files.purge
    end

    it "uploads the generated file" do
      expect { subject.perform_now(organization) }.to change { organization.open_data_files.attached? }.from(false).to(true)
    end

    context "when exporting a resource twice" do
      let(:resource) { "users" }
      let(:filename) { organization.open_data_file_path(resource) }
      let!(:first_user) { create(:user, :confirmed, organization:, name: "First exported user") }

      def resource_files
        organization.reload.open_data_files.select { |file| file.blob.filename.to_s == filename }
      end

      it "replaces the previous file with the refreshed one" do
        subject.perform_now(organization, resource)
        first_file = resource_files.first
        expect(first_file.blob.download).to include(first_user.name)

        second_user = create(:user, :confirmed, organization:, name: "Second exported user")
        subject.perform_now(organization, resource)

        expect(resource_files.size).to eq(1)
        refreshed_file = resource_files.first
        expect(refreshed_file.id).not_to eq(first_file.id)

        content = refreshed_file.blob.download
        expect(content).to include(first_user.name)
        expect(content).to include(second_user.name)
      end
    end
  end

  it "deletes the temporary file after finishing the job" do
    organization = create(:organization)

    expect(FileUtils).to receive(:rm_f) do |path|
      expect(path.to_s).to match(%r{tmp/.*})
    end
    described_class.perform_now(organization)
  end
end
