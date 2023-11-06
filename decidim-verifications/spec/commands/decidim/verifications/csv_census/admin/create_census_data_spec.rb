# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CreateCensusData do
    subject { described_class.new(form, organization) }

    let(:form) { CensusDataForm.new(file:) }
    let(:organization) { create(:organization) }

    context "when the file is in invalid format" do
      let(:file) { Decidim::Dev.test_file("import_participatory_space_private_users_iso8859-1.csv", "text/csv") }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
