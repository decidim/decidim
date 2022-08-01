# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VoteForm do
      subject { form }

      let(:form) { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create(:organization) }
      let!(:city) { create(:scope, organization:) }
      let!(:district1) { create(:subscope, parent: city) }
      let!(:district2) { create(:subscope, parent: city) }
      let!(:neighbourhood1) { create(:subscope, parent: district1) }
      let!(:neighbourhood2) { create(:subscope, parent: district2) }
      let!(:neighbourhood3) { create(:subscope, parent: district1) }
      let!(:neighbourhood4) { create(:subscope, parent: district2) }
      let!(:initiative_type) do
        create(
          :initiatives_type,
          organization:,
          document_number_authorization_handler:,
          child_scope_threshold_enabled:,
          collect_user_extra_fields:
        )
      end
      let!(:global_initiative_type_scope) { create(:initiatives_type_scope, scope: nil, type: initiative_type) }
      let!(:city_initiative_type_scope) { create(:initiatives_type_scope, scope: city, type: initiative_type) }
      let!(:district_1_initiative_type_scope) { create(:initiatives_type_scope, scope: district1, type: initiative_type) }
      let!(:district_2_initiative_type_scope) { create(:initiatives_type_scope, scope: district2, type: initiative_type) }
      let!(:neighbourhood_1_initiative_type_scope) { create(:initiatives_type_scope, scope: neighbourhood1, type: initiative_type) }
      let!(:neighbourhood_2_initiative_type_scope) { create(:initiatives_type_scope, scope: neighbourhood2, type: initiative_type) }
      let!(:neighbourhood_3_initiative_type_scope) { create(:initiatives_type_scope, scope: neighbourhood3, type: initiative_type) }
      let!(:authorization) do
        create(
          :authorization,
          :granted,
          name: "dummy_authorization_handler",
          user: current_user,
          unique_id: document_number,
          metadata: { document_number:, postal_code:, scope_id: user_scope.id }
        )
      end
      let(:user_scope) { district1 }
      let(:scoped_type) { district_1_initiative_type_scope }

      let(:initiative) do
        create(
          :initiative,
          organization:,
          scoped_type:
        )
      end
      let(:document_number_authorization_handler) { "dummy_authorization_handler" }
      let(:child_scope_threshold_enabled) { false }
      let(:collect_user_extra_fields) { false }

      let(:current_user) { create(:user, organization: initiative.organization) }

      let(:document_number) { "01234567A" }
      let(:postal_code) { "87111" }
      let(:personal_data) do
        {
          name_and_surname: "James Morgan McGill",
          document_number:,
          date_of_birth: 40.years.ago.to_date,
          postal_code:
        }
      end

      let(:vote_attributes) do
        {
          initiative:,
          signer: current_user
        }
      end
      let(:attributes) { personal_data.merge(vote_attributes) }
      let(:context) { { current_organization: organization } }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      describe "personal data" do
        context "when no personal data is required" do
          let(:collect_user_extra_fields) { false }

          context "when personal data is blank" do
            let(:personal_data) { {} }

            it { is_expected.to be_valid }
          end
        end

        context "when personal data is required" do
          let(:collect_user_extra_fields) { true }

          context "when personal data is blank" do
            let(:personal_data) { {} }

            it { is_expected.not_to be_valid }
          end

          context "when personal data is present" do
            it { is_expected.to be_valid }
          end
        end

        describe "#metadata" do
          subject { described_class.from_params(attributes).with_context(context).metadata }

          it { is_expected.to eq(personal_data) }
        end

        describe "#encrypted_metadata" do
          subject { described_class.from_params(attributes).with_context(context).encrypted_metadata }

          context "when no personal data is required" do
            let(:collect_user_extra_fields) { false }

            it { is_expected.to be_blank }
          end

          context "when personal data is required" do
            let(:collect_user_extra_fields) { true }

            it { is_expected.not_to eq(personal_data) }

            [:name_and_surname, :document_number, :date_of_birth, :postal_code].each do |personal_attribute|
              it { is_expected.not_to include(personal_data[personal_attribute].to_s) }
            end
          end
        end
      end

      describe "user_authorized_scope" do
        subject { form.user_authorized_scope }

        context "when a handler is configured" do
          it { is_expected.to eq(user_scope) }

          context "when the authorization metadata doesn't match" do
            before do
              authorization.metadata["scope_id"] = nil
              authorization.save!
            end

            it { is_expected.to be_nil }
          end
        end

        context "when no handler is configured" do
          let(:document_number_authorization_handler) { nil }

          it { is_expected.to eq(initiative.scope) }
        end

        context "when the authorization does not have metadata" do
          let!(:authorization) do
            create(
              :authorization,
              :granted,
              name: "dummy_authorization_handler",
              user: current_user,
              unique_id: document_number,
              metadata: nil
            )
          end

          it { is_expected.to be_nil }
        end
      end

      describe "authorized_scope_candidates" do
        context "when it's a global scope initiative" do
          let(:scoped_type) { global_initiative_type_scope }

          it "includes all the scopes of the organization" do
            expect(form.authorized_scope_candidates.compact).to match_array(organization.scopes)
          end

          it "includes the scope" do
            expect(form.authorized_scope_candidates).to include(nil)
          end
        end

        context "when it's a fixed scope" do
          let(:scoped_type) { district_1_initiative_type_scope }

          it "returns the scope descendants" do
            expect(form.authorized_scope_candidates).to match_array([neighbourhood1, neighbourhood3, district1])
          end
        end
      end

      describe "authorized_scopes" do
        subject { form.authorized_scopes }

        context "when the authorization is not valid" do
          subject { form }

          before do
            authorization.granted_at = nil
            authorization.save!
          end

          it { is_expected.not_to be_valid }
        end

        context "when an authorization is not needed" do
          let(:document_number_authorization_handler) { nil }

          it { is_expected.to eq([initiative.scope]) }
        end

        context "when the authorization is valid" do
          context "when it's a global scope initiative" do
            let(:scoped_type) { global_initiative_type_scope }

            context "when child scope voting is enabled" do
              let(:child_scope_threshold_enabled) { true }

              context "when the user scope has children" do
                let(:user_scope) { district1 }

                it { is_expected.to match_array([nil, city, district1]) }
              end

              context "when the user scope is a leaf" do
                let(:user_scope) { neighbourhood1 }

                it { is_expected.to match_array([nil, city, district1, neighbourhood1]) }
              end
            end

            context "when child scope voting is disabled" do
              let(:child_scope_threshold_enabled) { false }

              it { is_expected.to eq([nil]) }
            end
          end

          context "when it has a defined scope" do
            let(:scoped_type) { district_1_initiative_type_scope }

            context "when child scope voting is enabled" do
              let(:child_scope_threshold_enabled) { true }

              context "when the user scope has children" do
                let(:user_scope) { district1 }

                it { is_expected.to match_array([district1]) }
              end

              context "when the user scope is a leaf" do
                let(:user_scope) { neighbourhood1 }

                it { is_expected.to match_array([district1, neighbourhood1]) }
              end
            end

            context "when child scope voting is disabled" do
              let(:child_scope_threshold_enabled) { false }

              it { is_expected.to eq([district1]) }
            end
          end
        end
      end
    end
  end
end
