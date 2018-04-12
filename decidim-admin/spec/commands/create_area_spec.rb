# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateArea do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:name) { Decidim::Faker::Localized.literal(Faker::Address.unique.state) }
    let(:code) { Faker::Address.unique.state_abbr }
    let(:area_type) { create :area_type }

    let(:form) do
      double(
        invalid?: invalid,
        name: name,
        organization: organization,
        area_type: area_type
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

      it "creates a new area for the organization" do
        expect { subject.call }.to change { organization.areas.count }.by(1)
      end
    end
  end
end
