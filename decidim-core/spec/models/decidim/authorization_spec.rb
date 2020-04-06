# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Authorization do
    let(:authorization) { build(:authorization) }

    it "is valid" do
      expect(authorization).to be_valid
    end

    context "when leaving verification data around" do
      let(:authorization) do
        build(:authorization, verification_metadata: { sensible_stuff: "123456" })
      end

      it "is not valid" do
        expect(authorization).not_to be_valid
      end
    end

    context "when verification is granted" do
      let!(:authorization) { create(:authorization, name: "dummy_authorization_handler") }

      it "has renewable? method" do
        expect(authorization).to be_renewable
      end

      it "has cell_metadata" do
        expect(authorization.cell_metadata).to be_kind_of String
      end
    end
  end
end
