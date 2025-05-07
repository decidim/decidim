# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusDataForm do
    subject { described_class.from_params(file:) }

    context "when the file is in invalid format" do
      let(:file) { Decidim::Dev.test_file("import_participatory_space_private_users_iso8859-1.csv", "text/csv") }

      it { is_expected.not_to be_nil }
    end
  end
end
