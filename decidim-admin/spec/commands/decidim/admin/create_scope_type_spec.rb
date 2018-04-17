# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateScopeType do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:name) { Decidim::Faker::Localized.literal("province") }
    let(:plural) { Decidim::Faker::Localized.literal("provinces") }

    let(:form) do
      double(
        invalid?: invalid,
        name: name,
        organization: organization,
        plural: plural
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
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a new scope type for the organization" do
        expect { subject.call }.to change { organization.scope_types.count }.by(1)
      end
    end
  end
end
