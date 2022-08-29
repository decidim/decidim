# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ScopeType do
    subject(:scope_type) { build(:scope_type) }

    it { is_expected.to be_valid }

    describe "has an association for scopes" do
      subject(:scope_type_scopes) { scope_type.scopes }

      let(:scopes) { create_list(:scope, 2, scope_type:) }

      it { is_expected.to contain_exactly(*scopes) }
    end

    context "without name" do
      subject(:scope_type) { build(:scope_type, name: { en: "Name" }) }

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
