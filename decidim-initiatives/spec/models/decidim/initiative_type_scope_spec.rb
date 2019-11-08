# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesTypeScope do
    let(:initiatives_type_scope) { build :initiatives_type_scope }

    it "is valid" do
      expect(initiatives_type_scope).to be_valid
    end

    describe "scope_name" do
      let(:name) { initiatives_type_scope.scope_name["en"] }

      context "without a scope" do
        before do
          initiatives_type_scope.decidim_scopes_id = nil
        end

        it "returns the global scope name" do
          expect(name).to eq("Global scope")
        end
      end

      context "with an existing scope" do
        it "returns the scope name" do
          expect(name).to eq(initiatives_type_scope.scope.name["en"])
        end
      end

      context "with an invalid scope" do
        before do
          initiatives_type_scope.decidim_scopes_id = 9999
        end

        it "returns unavailable scope" do
          expect(name).to eq("Unavailable scope")
        end
      end
    end
  end
end
