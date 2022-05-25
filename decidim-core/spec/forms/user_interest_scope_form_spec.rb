# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserInterestScopeForm do
    subject do
      described_class.new(
        name: name,
        checked: checked,
        children: children
      )
    end

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization, extended_data: extended_data) }

    let!(:scope) { create(:scope, organization: organization) }
    let(:name) { scope.name }
    let(:checked) { true }
    let(:children) { [] }
    let(:extended_data) { {} }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "#map_model" do
      subject do
        described_class.from_model(model_hash)
      end

      let(:model_hash) { { scope: scope, user: user } }

      it "creates form" do
        expect(subject.id).to eq(scope.id)
        expect(subject.name).to eq(name)
        expect(subject.checked).to be(false)
        expect(subject.children).to eq(children)
      end

      context "when user has interested scope" do
        let(:extended_data) { { "interested_scopes" => [scope.id] } }

        it "checks the scope" do
          expect(subject.checked).to be(true)
        end
      end
    end
  end
end
