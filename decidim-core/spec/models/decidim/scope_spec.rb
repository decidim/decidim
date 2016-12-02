require "spec_helper"

module Decidim
  describe Scope do
    let(:scope) { build(:scope) }

    context "validations" do
      it "is valid" do
        expect(scope).to be_valid
      end

      it "does not allow two scopes with the same name in the same organization" do
        scope = create(:scope)
        invalid_scope = build(:scope, name: scope.name, organization: scope.organization)

        expect(invalid_scope).to_not be_valid
      end

      it "does allow two scopes with the same name in different organizations" do
        scope = create(:scope)
        other_scope = create(:scope, name: scope.name)

        expect(other_scope).to be_valid
      end

      it "is not valid without a name" do
        scope.name = ""
        expect(scope).not_to be_valid
      end
    end
  end
end
