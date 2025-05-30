# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CensusPermissionsForm do
        subject do
          described_class.from_params(verification_types: verification_types).with_context(current_organization: organization)
        end

        let(:organization) { create(:organization) }
        let(:verification_types) { %w(email_authorization postal_letter) }

        let!(:users_with_both_authorizations) do
          create_list(:user, 3, :confirmed, organization:).each do |user|
            verification_types.each do |type|
              create(:authorization, name: type, granted_at: 1.day.ago, user:)
            end
          end
        end

        let!(:users_with_one_authorization) do
          create_list(:user, 2, :confirmed, organization:).each do |user|
            create(:authorization, name: "email_authorization", granted_at: 1.day.ago, user:)
          end
        end

        let!(:users_without_authorizations) do
          create_list(:user, 2, :confirmed, organization:)
        end

        before do
          allow(organization).to receive(:available_authorizations).and_return(%w(email_authorization postal_letter))
        end

        describe "#data" do
          context "when both verification_types are selected" do
            it "returns only users with all required authorizations" do
              expect(subject.data).to match_array(users_with_both_authorizations)
            end
          end

          context "when only one verification_type is selected" do
            let(:verification_types) { ["email_authorization"] }

            it "returns users with at least that type" do
              expected_users = users_with_both_authorizations + users_with_one_authorization
              expect(subject.data).to match_array(expected_users)
            end
          end

          context "when no verification_types are selected" do
            let(:verification_types) { [] }

            let!(:all_users) do
              users_with_both_authorizations +
                users_with_one_authorization +
                users_without_authorizations
            end

            it "returns all confirmed users in the organization" do
              expect(subject.data).to match_array(all_users)
            end
          end
        end

        describe "#imported_count" do
          it "returns the count of users from data" do
            expect(subject.imported_count).to eq(subject.data.size)
          end
        end

        describe "#errors_data" do
          it "returns an empty array since the form is always valid" do
            expect(subject.errors_data).to eq([])
          end
        end
      end
    end
  end
end
