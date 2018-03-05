# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UsersOfficialization do
    subject { described_class.new(organization, search, filter) }

    let(:organization) { create :organization }
    let(:search) { nil }
    let(:filter) { nil }

    describe "when the list is not filtered" do
      let!(:users) { create_list(:user, 3, organization: organization) }
      let!(:other_org_users) { create_list(:user, 3) }

      it "returns all users" do
        expect(subject.query).to match_array users
        expect(Decidim::User.count).to eq 6
      end
    end

    describe "when the list is filtered" do
      context "and recieves a search param" do
        let!(:users) do
          %w(Walter Fargo Phargo).map do |name|
            create(:user, name: name, organization: organization)
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

      context "and recieves a filter param" do
        let!(:not_officialized_users) { create_list(:user, 2, organization: organization) }
        let!(:officialized_users) { create_list(:user, 2, :officialized, organization: organization) }

        context 'when the user filters by "Officialized"' do
          let(:filter) { "officialized" }

          it "returns all the officialized users" do
            expect(subject.query).to match_array(officialized_users)
          end
        end

        context 'when the user filters by "Non Officialized"' do
          let(:filter) { "not_officialized" }

          it "returns all the verified users" do
            expect(subject.query).to match_array(not_officialized_users)
          end
        end
      end

      context "and recieves a search and a filter param" do
        let(:officialized_users) do
          %w(Lorem Ipsum Dolor).map do |name|
            create(:user, :officialized, name: name, organization: organization)
          end
        end

        let(:_not_officialized_users) do
          %w(Elit Vivamus Doctum).map do |name|
            create(:user, name: name, organization: organization)
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
