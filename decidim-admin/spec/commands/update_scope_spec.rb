# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateScope do
    subject { described_class.new(scope, form) }

    let(:organization) { create :organization }
    let(:scope) { create :scope, organization: organization }
    let(:name) { Decidim::Faker::Localized.literal("New name") }
    let(:code) { "NEWCODE" }
    let(:scope_type) { create :scope_type, organization: organization }

    let(:form) do
      double(
        invalid?: invalid,
        name: name,
        code: code,
        scope_type: scope_type
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      before do
        subject.call
        scope.reload
      end

      it "updates the name of the scope" do
        expect(translated(scope.name)).to eq("New name")
      end

      it "updates the code of the scope" do
        expect(scope.code).to eq("NEWCODE")
      end

      it "updates the scope type" do
        expect(scope.scope_type).to eq(scope_type)
      end
    end
  end
end
