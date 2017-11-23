# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UserGroupsEvaluation do
    subject { described_class.new(Decidim::UserGroup.all, query, filter) }

    let(:organization) { create :organization }
    let(:query) { nil }
    let(:filter) { nil }

    describe "when the list is not filtered" do
      let!(:user_groups) { create_list(:user_group, 10, users: [create(:user, organization: organization)]) }

      it "returns all the user groups" do
        expect(subject.query).to eq user_groups
      end
    end

    describe "when the list is filtered" do
      context "and recieves a search param" do
        let(:user_groups) do
          %w(Walter Fargo Phargo)
            .map do |name|
            create(:user_group, name: name,
                                users: [create(:user, organization: organization)])
          end
        end

        let(:query) { "Argo" }

        it "returns all the user groups" do
          expect(subject.query).to match_array([user_groups[1], user_groups[2]])
        end
      end

      context "and recieves a filter param" do
        let!(:rejected_user_groups) { create_list(:user_group, 2, :rejected, users: [create(:user, organization: organization)]) }
        let!(:verified_user_groups) { create_list(:user_group, 5, :verified, users: [create(:user, organization: organization)]) }
        let!(:pedning_user_groups) { create_list(:user_group, 4, users: [create(:user, organization: organization)]) }

        context 'when the user filters by "Verified"' do
          let(:filter) { "verified" }

          it "returns all the verified user groups" do
            expect(subject.query.length).to eq(5)
          end
        end
        context 'when the user filters by "Rejected"' do
          let(:filter) { "rejected" }

          it "returns all the verified user groups" do
            expect(subject.query.length).to eq(2)
          end
        end
        context 'when the user filters by "Pending"' do
          let(:filter) { "pending" }

          it "returns all the verified user groups" do
            expect(subject.query.length).to eq(4)
          end
        end
      end

      context "and recieves a search and a filter aram" do
        let(:rejected_user_groups) do
          %w(Lorem Ipsum Dolor Amet)
            .map do |name|
            create(:user_group, :rejected, name: name,
                                           users: [create(:user, organization: organization)])
          end
        end
        let(:verified_user_groups) do
          %w(Elit Vivamus Doctum)
            .map do |name|
            create(:user_group, :verified, name: name,
                                           users: [create(:user, organization: organization)])
          end
        end
        let(:pending_user_groups) do
          %w(Walter Fargo Phargo)
            .map do |name|
            create(:user_group, name: name,
                                users: [create(:user, organization: organization)])
          end
        end
        let(:query) { "lo" }
        let(:filter) { "rejected" }

        it 'returns the "Rejected" user groups that contain the query search' do
          expect(subject.query).to match_array([rejected_user_groups[0], rejected_user_groups[2]])
        end
      end
    end
  end
end
