# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ParticipatorySpacePrivateUserCsvImportForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_user:,
          current_organization:
        )
      end

      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: current_organization) }

      let(:attributes) do
        {
          "file" => file
        }
      end
      let(:file) { upload_test_file(Decidim::Dev.asset("import_participatory_space_private_users.csv")) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when file is missing" do
        let(:file) { nil }

        it { is_expected.to be_invalid }
      end

      context "when user name contains invalid chars" do
        let(:file) { upload_test_file(Decidim::Dev.asset("import_participatory_space_private_users_nok.csv")) }

        it { is_expected.to be_invalid }
      end

      context "when the CSV separator is incorrect" do
        let(:file) { upload_test_file(Decidim::Dev.asset("import_participatory_space_private_users_invalid_col_sep.csv")) }

        it { is_expected.to be_invalid }
      end

      context "when the provided file is encoded with incorrect character set" do
        let(:file) { upload_test_file(Decidim::Dev.asset("import_participatory_space_private_users_iso8859-1.csv")) }

        it { is_expected.to be_invalid }

        it "adds the correct error" do
          subject.valid?
          expect(subject.errors[:file].join).to eq("Malformed import file, please read through the instructions carefully and make sure the file is UTF-8 encoded.")
        end
      end
    end
  end
end
