# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeForm do
        subject { described_class.from_model(initiative).with_context(context) }

        let(:organization) { create(:organization) }
        let(:initiatives_type) { create(:initiatives_type, organization:) }
        let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
        let(:other_scope) { create(:initiatives_type_scope, type: initiatives_type) }
        let(:state) { "published" }
        let(:attachment_params) { nil }

        let(:initiative) { create(:initiative, organization:, state:, scoped_type: scope) }
        let(:user) { create(:user, organization:) }

        let(:context) do
          {
            current_user: user,
            current_organization: organization,
            current_component: nil,
            initiative:
          }
        end

        let(:type_id) { initiatives_type.id }
        let(:decidim_scope_id) { scope.scope.id }

        let(:attributes) do
          {
            type_id:,
            decidim_scope_id:,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.sentence(word_count: 5),
            state: "created",
            signature_type: "online",
            attachment: attachment_params
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        describe "#map_model" do
          subject { described_class.from_model(initiative).with_context(context) }

          context "when there are offline votes" do
            context "with a specific scope" do
              context "when there are no votes" do
                it "returns the correct offline_votes" do
                  scope_name = scope.scope_name["en"]
                  expected = { initiative.scope.id.to_s.to_sym => [0, { "ca" => scope_name, "en" => scope_name, "es" => scope_name }] }
                  expect(subject.offline_votes).to eq expected
                end
              end

              context "when there are votes" do
                before { initiative.update!(offline_votes: { "total" => "100", initiative.scope.id.to_s => "100" }) }

                it "returns the correct offline_votes" do
                  scope_name = scope.scope_name["en"]
                  expected = { initiative.scope.id.to_s.to_sym => ["100", { "ca" => scope_name, "en" => scope_name, "es" => scope_name }] }
                  expect(subject.offline_votes).to eq expected
                end
              end
            end

            context "with the global scope" do
              let(:scope) { create(:initiatives_type_scope, scope: nil) }

              context "when there are no votes" do
                it "returns the correct offline_votes" do
                  expected = { global: [0, { "en" => "Global scope" }] }
                  expect(subject.offline_votes).to eq expected
                end
              end

              context "when there are votes" do
                before { initiative.update!(offline_votes: { "total" => "100", "global" => "100" }) }

                it "returns the correct offline_votes" do
                  expected = { global: ["100", { "en" => "Global scope" }] }
                  expect(subject.offline_votes).to eq expected
                end
              end
            end
          end
        end

        describe "#signature_type_updatable?" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          context "when created" do
            let(:state) { "created" }

            it { is_expected.to be(true) }
          end

          context "when validating" do
            let(:state) { "validating" }

            context "and user current_user is admin" do
              let(:user) { create(:user, :admin, organization:) }

              it { is_expected.to be(true) }
            end

            context "and current_user is not admin" do
              it { is_expected.to be(false) }
            end
          end

          context "when any other state" do
            it { is_expected.to be(false) }
          end
        end

        describe "#scoped_type_id" do
          context "when created from attributes" do
            subject { described_class.from_params(attributes).with_context(context).scoped_type_id }

            context "when type_id and decidim_scope_id from initiative are provided" do
              it { is_expected.to eq(initiative.scoped_type.id) }
            end

            context "when other decidim_scope_id is provided" do
              let(:decidim_scope_id) { other_scope.scope.id }

              it { is_expected.to eq(other_scope.id) }
            end

            context "when decidim_scope_id is blank" do
              let(:decidim_scope_id) { nil }

              it { is_expected.to be_nil }
            end

            context "when no type or decidim_scope_id are provided" do
              let(:attributes) do
                {
                  title: Decidim::Faker::Localized.sentence(word_count: 2),
                  description: Decidim::Faker::Localized.sentence(word_count: 5),
                  state: "created",
                  signature_type: "online"
                }
              end

              it { is_expected.to be_nil }
            end
          end

          context "when created from model" do
            subject { described_class.from_model(initiative).with_context(context).scoped_type_id }

            it { is_expected.to eq(initiative.scoped_type.id) }
          end
        end
      end
    end
  end
end
