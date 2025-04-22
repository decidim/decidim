# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe SignatureHandler do
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
          child_scope_threshold_enabled:
        )
      end
      let!(:global_initiative_type_scope) { create(:initiatives_type_scope, scope: nil, type: initiative_type) }
      let!(:city_initiative_type_scope) { create(:initiatives_type_scope, scope: city, type: initiative_type) }
      let!(:district_1_initiative_type_scope) { create(:initiatives_type_scope, scope: district1, type: initiative_type) }
      let!(:district_2_initiative_type_scope) { create(:initiatives_type_scope, scope: district2, type: initiative_type) }
      let!(:neighbourhood_1_initiative_type_scope) { create(:initiatives_type_scope, scope: neighbourhood1, type: initiative_type) }
      let!(:neighbourhood_2_initiative_type_scope) { create(:initiatives_type_scope, scope: neighbourhood2, type: initiative_type) }
      let!(:neighbourhood_3_initiative_type_scope) { create(:initiatives_type_scope, scope: neighbourhood3, type: initiative_type) }
      let!(:user_scope) { district1 }
      let(:scoped_type) { district_1_initiative_type_scope }

      let(:initiative) do
        create(
          :initiative,
          organization:,
          scoped_type:
        )
      end
      let(:child_scope_threshold_enabled) { false }

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

      let(:attributes) do
        {
          initiative:,
          user: current_user,
          scope: user_scope
        }
      end
      let(:context) { { current_organization: organization } }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      describe "#encrypted_metadata" do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(described_class).to receive(:metadata).and_return(personal_data)
          # rubocop:enable RSpec/AnyInstance
        end

        subject { described_class.from_params(attributes).with_context(context).encrypted_metadata }

        context "when personal data is required" do
          it { is_expected.not_to eq(personal_data) }

          [:name_and_surname, :document_number, :date_of_birth, :postal_code].each do |personal_attribute|
            it { is_expected.not_to include(personal_data[personal_attribute].to_s) }
          end
        end
      end

      describe "user_signature_scope" do
        subject { form.user_signature_scope }

        context "when a scope is passed as argument" do
          it { is_expected.to eq(user_scope) }
        end

        context "when no scope is passed as argument" do
          let(:attributes) do
            {
              initiative:,
              user: current_user
            }
          end

          it { is_expected.to eq(initiative.scope) }
        end
      end

      describe "signature_scope_candidates" do
        context "when it is a global scope initiative" do
          let(:scoped_type) { global_initiative_type_scope }

          it "includes all the scopes of the organization" do
            expect(form.signature_scope_candidates.compact).to match_array(organization.scopes)
          end

          it "includes the scope" do
            expect(form.signature_scope_candidates).to include(nil)
          end
        end

        context "when it is a fixed scope" do
          let(:scoped_type) { district_1_initiative_type_scope }

          it "returns the scope descendants" do
            expect(form.signature_scope_candidates).to contain_exactly(neighbourhood1, neighbourhood3, district1)
          end
        end
      end

      describe "authorized_scopes" do
        before do
          # The signature_scope_id is an attribute set by default as
          # the initiative scope id, but all classes inherited from this can
          # take the attribute from other source or provided by the user in the
          # personal data collection step. This mock allows us to test the
          # authorized_scopes considering different signature_scope_id values
          #
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(described_class).to receive(:signature_scope_id).and_return(user_scope.id)
          # rubocop:enable RSpec/AnyInstance
        end

        subject { form.authorized_scopes }

        it { is_expected.to eq([initiative.scope]) }

        context "when it is a global scope initiative" do
          let(:scoped_type) { global_initiative_type_scope }

          context "when child scope voting is enabled" do
            let(:child_scope_threshold_enabled) { true }

            context "when signature_scope_id is set" do
              context "when the user scope has children" do
                let!(:user_scope) { district1 }

                it { is_expected.to contain_exactly(nil, city, district1) }
              end

              context "when the user scope is a leaf" do
                let!(:user_scope) { neighbourhood1 }

                it { is_expected.to contain_exactly(nil, city, district1, neighbourhood1) }
              end
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
              let!(:user_scope) { district1 }

              it { is_expected.to contain_exactly(district1) }
            end

            context "when the user scope is a leaf" do
              let!(:user_scope) { neighbourhood1 }

              it { is_expected.to(contain_exactly(district1, neighbourhood1)) }
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
