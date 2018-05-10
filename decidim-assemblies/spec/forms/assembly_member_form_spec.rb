# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyMemberForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:context) do
          {
            current_organization: organization
          }
        end

        let(:full_name) { "Full name" }
        let(:designation_date) { Time.current }
        let(:gender) { ::Faker::Lorem.word }
        let(:position) { Decidim::AssemblyMember::POSITIONS.first }

        let(:attributes) do
          {
            "assembly_member" => {
              "full_name" => full_name,
              "designation_date" => designation_date,
              "gender" => gender,
              "position" => position,
              "birthday" => Time.current
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when full name is missing" do
          let(:full_name) { nil }

          it { is_expected.to be_invalid }
        end

        context "when designation date is missing" do
          let(:designation_date) { nil }

          it { is_expected.to be_invalid }
        end

        describe "position" do
          context "when is missing" do
            let(:position) { nil }

            it { is_expected.to be_invalid }
          end

          context "when not included in the list" do
            let(:position) { "not-included" }

            it { is_expected.to be_invalid }
          end

          context "when is other" do
            let(:position) { "other" }

            context "and it's not specified" do
              subject(:form) { described_class.from_params(attributes.merge(position_other: "")).with_context(context) }

              it { is_expected.to be_invalid }
            end
          end
        end

        context "when ceased date is present" do
          context "and is older than designation date" do
            subject(:form) { described_class.from_params(attributes.merge(ceased_date: (designation_date - 1.minute))).with_context(context) }

            it { is_expected.to be_invalid }
          end

          context "and is equal to designation date" do
            subject(:form) { described_class.from_params(attributes.merge(ceased_date: designation_date)).with_context(context) }

            it { is_expected.to be_invalid }
          end

          context "and is future to designation date" do
            subject(:form) { described_class.from_params(attributes.merge(ceased_date: (designation_date + 1.minute))).with_context(context) }

            it { is_expected.to be_valid }
          end
        end
      end
    end
  end
end
