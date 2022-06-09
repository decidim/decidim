# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user, :admin }
  let(:current_component) { create(:proposal_component) }
  let(:proposal) { nil }
  let(:extra_context) { {} }
  let(:context) do
    {
      proposal: proposal,
      current_component: current_component,
      current_settings: current_settings,
      component_settings: component_settings
    }.merge(extra_context)
  end
  let(:component_settings) do
    double(
      official_proposals_enabled: official_proposals_enabled?,
      proposal_answering_enabled: component_settings_proposal_answering_enabled?,
      participatory_texts_enabled?: component_settings_participatory_texts_enabled?
    )
  end
  let(:current_settings) do
    double(
      creation_enabled?: creation_enabled?,
      proposal_answering_enabled: current_settings_proposal_answering_enabled?,
      publish_answers_immediately: current_settings_publish_answers_immediately?
    )
  end
  let(:creation_enabled?) { true }
  let(:official_proposals_enabled?) { true }
  let(:component_settings_proposal_answering_enabled?) { true }
  let(:component_settings_participatory_texts_enabled?) { false }
  let(:current_settings_proposal_answering_enabled?) { true }
  let(:current_settings_publish_answers_immediately?) { true }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  shared_examples "can create proposal notes" do
    describe "proposal note creation" do
      let(:action) do
        { scope: :admin, action: :create, subject: :proposal_note }
      end

      context "when the space allows it" do
        it { is_expected.to be true }
      end
    end
  end

  shared_examples "can answer proposals" do
    describe "proposal answering" do
      let(:action) do
        { scope: :admin, action: :create, subject: :proposal_answer }
      end

      context "when everything is OK" do
        it { is_expected.to be true }
      end

      context "when answering is disabled in the step level" do
        let(:current_settings_proposal_answering_enabled?) { false }

        it { is_expected.to be false }
      end

      context "when answering is disabled in the component level" do
        let(:component_settings_proposal_answering_enabled?) { false }

        it { is_expected.to be false }
      end
    end
  end

  shared_examples "can export proposals" do
    describe "export proposals" do
      let(:action) do
        { scope: :admin, action: :export, subject: :proposals }
      end

      context "when everything is OK" do
        it { is_expected.to be true }
      end
    end
  end

  context "when user is a valuator" do
    let(:organization) { space.organization }
    let(:space) { current_component.participatory_space }
    let!(:valuator_role) { create :participatory_process_user_role, user: user, role: :valuator, participatory_process: space }
    let!(:user) { create :user, organization: organization }

    context "and can valuate the current proposal" do
      let(:proposal) { create :proposal, component: current_component }
      let!(:assignment) { create :valuation_assignment, proposal: proposal, valuator_role: valuator_role }

      it_behaves_like "can create proposal notes"
      it_behaves_like "can answer proposals"
      it_behaves_like "can export proposals"
    end

    context "when current user is the valuator" do
      describe "unassign proposals from themselves" do
        let(:action) do
          { scope: :admin, action: :unassign_from_valuator, subject: :proposals }
        end
        let(:extra_context) { { valuator: user } }

        it { is_expected.to be true }
      end
    end
  end

  it_behaves_like "can create proposal notes"
  it_behaves_like "can answer proposals"
  it_behaves_like "can export proposals"

  describe "proposal creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :proposal }
    end

    context "when everything is OK" do
      it { is_expected.to be true }
    end

    context "when creation is disabled" do
      let(:creation_enabled?) { false }

      it { is_expected.to be false }
    end

    context "when official proposals are disabled" do
      let(:official_proposals_enabled?) { false }

      it { is_expected.to be false }
    end

    context "when participatory texts is enabled" do
      let(:component_settings_participatory_texts_enabled?) { true }

      it { is_expected.to be false }
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

      context "when everything is OK" do
        it { is_expected.to be true }
      end

      context "when it has some votes" do
        before do
          create :proposal_vote, proposal: proposal
        end

        it_behaves_like "permission is not set"
      end
    end
  end

  describe "update proposal category" do
    let(:action) do
      { scope: :admin, action: :update, subject: :proposal_category }
    end

    it { is_expected.to be true }
  end

  describe "import proposals from another component" do
    let(:action) do
      { scope: :admin, action: :import, subject: :proposals }
    end

    it { is_expected.to be true }
  end

  describe "split proposals" do
    let(:action) do
      { scope: :admin, action: :split, subject: :proposals }
    end

    it { is_expected.to be true }
  end

  describe "merge proposals" do
    let(:action) do
      { scope: :admin, action: :merge, subject: :proposals }
    end

    it { is_expected.to be true }
  end

  describe "proposal answers publishing" do
    let(:user) { create(:user) }
    let(:action) do
      { scope: :admin, action: :publish_answers, subject: :proposals }
    end

    it { is_expected.to be false }

    context "when user is an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end
  end

  describe "assign proposals to a valuator" do
    let(:action) do
      { scope: :admin, action: :assign_to_valuator, subject: :proposals }
    end

    it { is_expected.to be true }
  end

  describe "unassign proposals from a valuator" do
    let(:action) do
      { scope: :admin, action: :unassign_from_valuator, subject: :proposals }
    end

    it { is_expected.to be true }
  end

  describe "manage participatory texts" do
    let(:component_settings_participatory_texts_enabled?) { true }
    let(:action) do
      { scope: :admin, action: :manage, subject: :participatory_texts }
    end

    it { is_expected.to be true }
  end
end
