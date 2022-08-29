# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::Admin::DatasetForm do
  subject { described_class.from_params(file:).with_context(current_participatory_space: voting) }

  let(:voting) { create(:voting) }
  let(:file) { upload_test_file(Decidim::Dev.test_file("import_voting_census.csv", "text/csv")) }

  it { is_expected.to be_valid }

  describe "when file is missing" do
    let(:file) { nil }

    it { is_expected.to be_invalid }
  end
end
