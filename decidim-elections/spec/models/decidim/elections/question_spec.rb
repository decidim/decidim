# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Question do
  subject(:question) { build(:question) }

  it { is_expected.to be_valid }

  include_examples "resourceable"

  context "when it has a relationship with a ballot style" do
    subject(:question) { create(:question, election: election) }

    let(:election) { create(:election) }
    let(:ballot_styles) { create_list(:ballot_style, 3, :with_ballot_style_questions, election: election) }

    it { expect(subject.ballot_styles).to match_array(ballot_styles) }
  end
end
