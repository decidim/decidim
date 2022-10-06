# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UserGroupsEvaluation do
    subject { described_class.new(Decidim::UserGroup.all, search, filter) }

    let(:organization) { create :organization }
    let(:search) { nil }
    let(:filter) { nil }

    describe "when the list is not filtered" do
      let!(:user_groups) { create_list(:user_group, 3, users: [create(:user, organization:)]) }

      it "returns all the user groups" do
        expect(subject.query).to match_array(user_groups)
      end
    end

    describe "when the list is filtered" do
      context "and receives a search param" do
        let(:user_groups) do
          %w(Walter Fargo Phargo).map do |name|
            create(:user_group, name:,
                                users: [create(:user, organization:)])
          end
        end

        context "with regular characters" do
          let(:search) { "Argo" }

          it "returns all matching users" do
            expect(subject.query).to match_array([user_groups[1], user_groups[2]])
          end
        end

        context "with conflictive characters" do
          let(:search) { "Andy O'Connel" }

          it "returns all matching users" do
            expect(subject.query).to be_empty
          end
        end
      end

      context "and receives a filter param" do
        let!(:rejected_user_groups) { create_list(:user_group, 2, :rejected, users: [create(:user, organization:)]) }
        let!(:verified_user_groups) { create_list(:user_group, 5, :verified, users: [create(:user, organization:)]) }
        let!(:pending_user_groups) { create_list(:user_group, 4, users: [create(:user, organization:)]) }

        context 'when the user filters by "Verified"' do
          let(:filter) { "verified" }

          it "returns all the verified user groups" do
            expect(subject.query).to match_array(verified_user_groups)
          end
        end

        context 'when the user filters by "Rejected"' do
          let(:filter) { "rejected" }

          it "returns all the verified user groups" do
            expect(subject.query).to match_array(rejected_user_groups)
          end
        end

        context 'when the user filters by "Pending"' do
          let(:filter) { "pending" }

          it "returns all the verified user groups" do
            expect(subject.query).to match_array(pending_user_groups)
          end
        end
      end

      context "and receives a search and a filter aram" do
        let(:rejected_user_groups) do
          %w(Lorem Ipsum Dolor).map do |name|
            create(:user_group, :rejected, name:,
                                           users: [create(:user, organization:)])
          end
        end

        let(:search) { "lo" }
        let(:filter) { "rejected" }

        before do
          %w(Elit Vivamus Doctum).map do |name|
            create(:user_group, :verified, name:,
                                           users: [create(:user, organization:)])
          end

          %w(Walter Fargo Phargo).map do |name|
            create(:user_group, name:,
                                users: [create(:user, organization:)])
          end
        end

        it 'returns the "Rejected" user groups that contain the query search' do
          expect(subject.query).to match_array([rejected_user_groups[0], rejected_user_groups[2]])
        end
      end
    end
  end
end
