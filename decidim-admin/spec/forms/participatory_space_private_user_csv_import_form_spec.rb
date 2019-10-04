# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ParticipatorySpacePrivateUserCsvImportForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          "file" => file
        }
      end
      let(:file) { File.new Decidim::Dev.asset("import_participatory_space_private_users.csv") }

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
