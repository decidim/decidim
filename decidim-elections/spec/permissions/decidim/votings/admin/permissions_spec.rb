# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: organization }
  let(:organization) { create :organization }
  let(:voting) { create :voting, organization: organization }
  let(:context) { { participatory_space: voting }.merge(extra_context) }
  let(:extra_context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  context "when the action is not for the admin part" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end

  context "when the user is not an admin" do
    let(:user) { create :user, organization: organization }
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it { is_expected.to be false }
  end

  describe "participatory spaces" do
    let(:action_subject) { :participatory_space }
    let(:action_name) { :read }

    it { is_expected.to be true }
  end

  describe "components" do
    let(:action_subject) { :components }
    let(:action_name) { :read }
    let(:extra_context) do
      { participatory_space: voting }
    end

    it { is_expected.to be true }
  end

  describe "votings" do
    let(:action_subject) { :voting }

    context "when creating a voting" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading a voting" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end
  end

  describe "census" do
    let(:action_subject) { :census }

    context "when managing a census" do
      let(:action_name) { :manage }

      it { is_expected.to be true }
    end
  end

  describe "monitoring committee" do
    context "when the user is an admin" do
      context "when reading the Committee Members" do
        let(:action_subject) { :monitoring_committee_members }
        let(:action_name) { :read }

        it { is_expected.to be true }
      end

      context "when reading the Certificates" do
        let(:action_subject) { :monitoring_committee_polling_station_closures }
        let(:action_name) { :read }

        it { is_expected.to be false }
      end
    end

    context "when the user is a Monitoring Committee Member" do
      let(:user) { create :user, organization: organization }
      let!(:monitoring_committee_member) { create(:monitoring_committee_member, user: user, voting: voting) }

      context "when accessing the admin panel" do
        let(:action_subject) { :admin_dashboard }
        let(:action_name) { :read }

        it { is_expected.to be true }
      end

      context "when reading the votings" do
        let(:action_subject) { :votings }
        let(:action_name) { :read }

        it { is_expected.to be true }
      end

      context "when listing their voting" do
        let(:action_subject) { :voting }
        let(:action_name) { :list }

        it { is_expected.to be true }
      end

      context "when listing another voting" do
        let(:other_voting) { create(:voting, organization: organization) }
        let!(:monitoring_committee_member) { create(:monitoring_committee_member, user: user, voting: other_voting) }
        let(:action_subject) { :voting }
        let(:action_name) { :list }

        it { is_expected.to be false }
      end

      context "when reading their voting's Polling Officers" do
        let(:action_subject) { :polling_officers }
        let(:action_name) { :read }

        it { is_expected.to be false }
      end

      context "when reading their voting's Committee Members" do
        let(:action_subject) { :monitoring_committee_members }
        let(:action_name) { :read }

        it { is_expected.to be false }
      end

      context "when reading their voting's Certificates" do
        let(:action_subject) { :monitoring_committee_polling_station_closures }
        let(:action_name) { :read }

        it { is_expected.to be true }
      end
    end
  end

  describe "ballot styles" do
    let(:action_subject) { :ballot_style }

    context "when updating a ballot style" do
      let(:action_name) { :update }
      let(:extra_context) { { ballot_style: ballot_style } }
      let(:ballot_style) { create(:ballot_style, voting: voting) }

      context "when census ballot style is not present" do
        let(:ballot_style) { nil }

        it { is_expected.to be false }
      end

      context "when census dataset is not present" do
        it { is_expected.to be true }
      end

      context "when census dataset is in init_data status" do
        let!(:dataset) { create(:dataset, voting: voting, status: :init_data) }

        it { is_expected.to be true }
      end

      context "when census dataset is in another status" do
        let!(:dataset) { create(:dataset, voting: voting, status: :data_created) }

        it { is_expected.to be false }
      end
    end
  end
end
