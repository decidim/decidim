# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UserFilter do
    subject { described_class.new(organization.users, search, filter) }

    let(:organization) { create :organization }
    let(:search) { nil }
    let(:filter) { nil }

    describe "when the list is not filtered" do
      let!(:users) { create_list(:user, 3, organization:) }
      let!(:other_org_users) { create_list(:user, 3) }

      it "returns all users" do
        expect(subject.query).to match_array users
        expect(Decidim::User.count).to eq 6
      end
    end

    describe "when the list is filtered" do
      context "and receives a search param" do
        let!(:users) do
          %w(Walter Fargo Phargo).map do |name|
            create(:user, name:, organization:)
          end
        end

        context "with regular characters" do
          let(:search) { "Argo" }

          it "returns all matching users" do
            expect(subject.query).to match_array([users[1], users[2]])
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
        let!(:regular_users) { create_list(:user, 2, organization:) }
        let!(:not_officialized_users) { regular_users + managed_users }
        let!(:officialized_users) { create_list(:user, 2, :officialized, organization:) }
        let!(:not_managed_users) { regular_users + officialized_users }
        let!(:managed_users) { create_list(:user, 2, :managed, organization:) }
        let(:all_users) { regular_users + officialized_users + managed_users }

        context 'when filtering by "Officialized"' do
          let(:filter) { "officialized" }

          it "returns all the officialized users" do
            expect(subject.query).to match_array(officialized_users)
          end
        end

        context 'when filtering by "Non Officialized"' do
          let(:filter) { "not_officialized" }

          it "returns all the non officialized users" do
            expect(subject.query).to match_array(not_officialized_users)
          end
        end

        context 'when filtering by "Managed"' do
          let(:filter) { "managed" }

          it "returns all the officialized users" do
            expect(subject.query).to match_array(managed_users)
          end
        end

        context 'when filtering by "Non Managed"' do
          let(:filter) { "not_managed" }

          it "returns all the non managed users" do
            expect(subject.query).to match_array(not_managed_users)
          end
        end

        context "when using an arbitrary filter" do
          let(:filter) { "destroy_all" }

          it "is ignored" do
            expect(subject.query).to match_array(all_users)
          end
        end
      end

      context "and receives a search and a filter param" do
        let(:officialized_users) do
          %w(Lorem Ipsum Dolor).map do |name|
            create(:user, :officialized, name:, organization:)
          end
        end

        let(:_not_officialized_users) do
          %w(Elit Vivamus Doctum).map do |name|
            create(:user, name:, organization:)
          end
        end

        let(:search) { "lo" }
        let(:filter) { "officialized" }

        it 'returns the "Officialized" users that contain the query search' do
          expect(subject.query).to match_array([officialized_users[0], officialized_users[2]])
        end
      end
    end
  end
end
