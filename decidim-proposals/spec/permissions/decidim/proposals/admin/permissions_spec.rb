# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user }
  let(:current_component) { create(:proposal_component) }
  let(:proposal) { nil }
  let(:context) do
    {
      proposal: proposal,
      current_component: current_component,
      current_settings: current_settings,
      component_settings: component_settings
    }
  end
  let(:component_settings) do
    double(
      official_proposals_enabled: official_proposals_enabled?,
      proposal_answering_enabled: component_settings_proposal_answering_enabled?
    )
  end
  let(:current_settings) do
    double(
      creation_enabled?: creation_enabled?,
      proposal_answering_enabled: current_settings_proposal_answering_enabled?
    )
  end
  let(:creation_enabled?) { true }
  let(:official_proposals_enabled?) { true }
  let(:component_settings_proposal_answering_enabled?) { true }
  let(:current_settings_proposal_answering_enabled?) { true }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  describe "proposal note creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :proposal_note }
    end

    context "when the space allows it" do
      it { is_expected.to eq true }
    end
  end

  describe "proposal creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :proposal }
    end

    context "when everything is OK" do
      it { is_expected.to eq true }
    end

    context "when creation is disabled" do
      let(:creation_enabled?) { false }

      it { is_expected.to eq false }
    end

    context "when official proposals are disabled" do
      let(:official_proposals_enabled?) { false }

      it { is_expected.to eq false }
    end
  end

  describe "proposal edition" do
    let(:action) do
      { scope: :admin, action: :edit, subject: :proposal }
    end

    context "when the proposal is not official" do
      let(:proposal) { create :proposal, component: current_component }

      it_behaves_like "permission is not set"
    end

    context "when the proposal is official" do
      let(:proposal) { create :proposal, :official, component: current_component }
      let(:within_edit_time_limit?) { true }

      before do
        allow(proposal).to receive(:within_edit_time_limit?).and_return(within_edit_time_limit?)
      end

      context "when everything is OK" do
        it { is_expected.to eq true }
      end

      context "when creation is disabled" do
        let(:creation_enabled?) { false }

        it_behaves_like "permission is not set"
      end

      context "when outside the edit time limit" do
        let(:within_edit_time_limit?) { false }

        it_behaves_like "permission is not set"
      end
    end
  end

  describe "proposal answering" do
    let(:action) do
      { scope: :admin, action: :create, subject: :proposal_answer }
    end

    context "when everything is OK" do
      it { is_expected.to eq true }
    end

    context "when answering is disabled in the step level" do
      let(:current_settings_proposal_answering_enabled?) { false }

      it { is_expected.to eq false }
    end

    context "when answering is disabled in the component level" do
      let(:component_settings_proposal_answering_enabled?) { false }

      it { is_expected.to eq false }
    end
  end

  describe "update proposal category" do
    let(:action) do
      { scope: :admin, action: :update, subject: :proposal_category }
    end

    it { is_expected.to eq true }
  end

  describe "import proposals from another component" do
    let(:action) do
      { scope: :admin, action: :import, subject: :proposals }
    end

    it { is_expected.to eq true }
  end
end
