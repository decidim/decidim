# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativeForm do
        subject { described_class.from_model(initiative).with_context(context) }

        let(:organization) { create(:organization) }
        let(:initiatives_type) { create(:initiatives_type, organization: organization) }
        let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
        let(:other_scope) { create(:initiatives_type_scope, type: initiatives_type) }
        let(:state) { "published" }
        let(:attachment_params) { nil }

        let(:initiative) { create(:initiative, organization: organization, state: state, scoped_type: scope) }
        let(:user) { create(:user, organization: organization) }

        let(:context) do
          {
            current_user: user,
            current_organization: organization,
            current_component: nil,
            initiative: initiative
          }
        end

        let(:type_id) { initiatives_type.id }
        let(:decidim_scope_id) { scope.scope.id }

        let(:attributes) do
          {
            type_id: type_id,
            decidim_scope_id: decidim_scope_id,
            title: Decidim::Faker::Localized.sentence(2),
            description: Decidim::Faker::Localized.sentence(5),
            state: "created",
            signature_type: "online",
            attachment: attachment_params
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        describe "#signature_type_updatable?" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          context "when created" do
            let(:state) { "created" }

            it { is_expected.to eq(true) }
          end

          context "when validating" do
            let(:state) { "validating" }

            context "and user current_user is admin" do
              let(:user) { create(:user, :admin, organization: organization) }

              it { is_expected.to eq(true) }
            end

            context "and current_user is not admin" do
              it { is_expected.to eq(false) }
            end
          end

          context "when any other state" do
            it { is_expected.to eq(false) }
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
                  title: Decidim::Faker::Localized.sentence(2),
                  description: Decidim::Faker::Localized.sentence(5),
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
