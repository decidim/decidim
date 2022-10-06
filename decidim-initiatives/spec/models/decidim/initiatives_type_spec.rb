# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesType do
    let(:initiatives_type) { build :initiatives_type }

    it "is valid" do
      expect(initiatives_type).to be_valid
    end

    describe "::initiatives" do
      let(:organization) { create(:organization) }
      let(:initiatives_type) { create(:initiatives_type, organization:) }
      let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
      let!(:initiative) { create(:initiative, organization:, scoped_type: scope) }
      let!(:other_initiative) { create(:initiative) }

      it "returns initiatives" do
        expect(initiatives_type.initiatives).to include(initiative)
        expect(initiatives_type.initiatives).not_to include(other_initiative)
      end
    end
  end
end
