# frozen_string_literal: true

require "spec_helper"

describe Decidim::Coauthorship do
  subject { coauthorship }

  let(:coauthorship) { build(:coauthorship) }

  describe "validations" do
    context "when the coauthorable is nil" do
      before do
        coauthorship.coauthorable = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when the author is from another organization" do
      before do
        subject.author = create(:user)
      end

      it { is_expected.to be_invalid }
    end
  end
end
