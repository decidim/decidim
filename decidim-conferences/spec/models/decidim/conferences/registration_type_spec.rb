# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe RegistrationType do
      subject { registration_type }

      let(:registration_type) { build(:registration_type) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "uses the conference's registration_types association as the inverse" do
        subject.save!

        expect(subject.conference.registration_types.first.conference).to be(subject.conference)
      end

      describe "associations" do
        it "has an association of conference_invites" do
          invite = create(:conference_invite, registration_type:)

          expect(registration_type.conference_invites).to eq([invite])
        end

        it "uses the conference_invites association as the inverse of the registration type" do
          create(:conference_invite, registration_type:)

          expect(registration_type.conference_invites.first.registration_type).to be(registration_type)
        end
      end

      describe ".default_scope" do
        it "returns registration types ordered by weight asc" do
          registration_type1 = create(:registration_type, price: 300.00, weight: 2, title: { en: "Registration type 1" })
          registration_type2 = create(:registration_type, price: 200.00, weight: 1, title: { en: "Registration type 2" })
          registration_type3 = create(:registration_type, price: 245.00, weight: 3, title: { en: "Registration type 3" })

          expected_result = [
            registration_type2,
            registration_type1,
            registration_type3
          ]

          expect(described_class.all).to eq expected_result
        end
      end

      describe "#participatory_space" do
        it "is an alias for #conference" do
          expect(registration_type.conference).to eq registration_type.participatory_space
        end
      end
    end
  end
end
