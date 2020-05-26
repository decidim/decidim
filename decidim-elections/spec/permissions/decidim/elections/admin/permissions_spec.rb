# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: elections_component.organization }
  let(:context) do
    {
      current_component: elections_component,
      election: election
    }
  end
  let(:elections_component) { create :elections_component }
  let(:election) { create :election, component: elections_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  shared_examples "not allowed when election has started" do
    context "when election has started" do
      let(:election) { create :election, :started, component: elections_component }

      it { is_expected.to eq false }
    end
  end

  shared_examples "allowed when election has started" do
    context "when election has started" do
      let(:election) { create :election, :started, component: elections_component }

      it { is_expected.to eq true }
    end
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not an election" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  describe "election creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :election }
    end

    it { is_expected.to eq true }
  end

  describe "election update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :election }
    end

    it { is_expected.to eq true }

    it_behaves_like "allowed when election has started"
  end

  describe "election delete" do
    let(:action) do
      { scope: :admin, action: :delete, subject: :election }
    end

    it { is_expected.to eq true }

    it_behaves_like "not allowed when election has started"
  end

  describe "questions" do
    let(:election) { create :election, component: elections_component }

    describe "question creation" do
      let(:action) do
        { scope: :admin, action: :create, subject: :question }
      end

      it { is_expected.to eq true }

      it_behaves_like "not allowed when election has started"
    end

    describe "question update" do
      let(:action) do
        { scope: :admin, action: :update, subject: :question }
      end

      it { is_expected.to eq true }

      it_behaves_like "not allowed when election has started"
    end

    describe "question delete" do
      let(:action) do
        { scope: :admin, action: :delete, subject: :question }
      end

      it { is_expected.to eq true }

      it_behaves_like "not allowed when election has started"
    end
  end
end
