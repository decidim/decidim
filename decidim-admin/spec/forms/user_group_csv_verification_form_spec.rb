# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe UserGroupCsvVerificationForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          "file" => file
        }
      end
      let(:file) { upload_test_file(Decidim::Dev.test_file("verify_user_groups.csv", "text/csv"), return_blob: true) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when file is missing" do
        let(:file) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
