# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ScopeType do
    let(:scope_type) { build(:scope_type) }
    subject { scope_type }

    it { is_expected.to be_valid }

    context "without name" do
      before do
        scope_type.name = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        scope_type.organization = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
