# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: component.organization) }
  let(:component) { create(:elections_component) }
  let(:election) { create(:election, component:) }
  let(:context) do
    {
      current_component: component,
      election:
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(scope: scope, action: action_name, subject: action_subject) }
  let(:scope) { :admin }
  let(:action_name) { :foo }
  let(:action_subject) { :foo }

  shared_examples "requires an election" do
    context "when election is present" do
      it { is_expected.to be true }
    end

    context "when election is missing" do
      let(:election) { nil }

      it { is_expected.to be false }
    end
  end

  context "when user is nil" do
    let(:user) { nil }

    it_behaves_like "permission is not set"
  end

  context "when scope is not admin" do
    let(:scope) { :public }
    let(:action_name) { :create }
    let(:action_subject) { :election }

    it_behaves_like "permission is not set"
  end

  context "when subject is unknown" do
    let(:action_subject) { :unknown }

    it_behaves_like "permission is not set"
  end

  context "when subject is election" do
    let(:action_subject) { :election }

    context "when creating" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end

    context "when updating" do
      let(:action_name) { :update }

      it_behaves_like "requires an election"
    end

    context "when publishing" do
      let(:action_name) { :publish }

      context "when conditions are met" do
        before do
          create(:election_question, election:)
          allow(election).to receive(:census_ready?).and_return(true)
        end

        it { is_expected.to be true }
      end

      context "when already published" do
        let(:election) { create(:election, component:, published_at: 1.day.ago) }

        before do
          create(:election_question, election:)
          allow(election).to receive(:census_ready?).and_return(true)
        end

        it { is_expected.to be false }
      end

      context "when requirements are not met" do
        before do
          create(:election_question, election:)
          allow(election).to receive(:census_ready?).and_return(false)
        end

        it { is_expected.to be false }
      end
    end

    context "when unpublishing" do
      let(:action_name) { :unpublish }

      context "when election is published and not ongoing" do
        let(:election) { create(:election, component:, published_at: 2.days.ago, start_at: 1.day.from_now) }

        it { is_expected.to be true }
      end

      context "when not published" do
        let(:election) { create(:election, component:, published_at: nil) }

        it { is_expected.to be false }
      end

      context "when already ongoing" do
        let(:election) { create(:election, component:, published_at: 2.days.ago, start_at: 1.day.ago) }

        it { is_expected.to be false }
      end
    end

    context "when accessing dashboard" do
      let(:action_name) { :dashboard }

      before { allow(election).to receive(:census_ready?).and_return(true) }

      it { is_expected.to be true }
    end
  end

  context "when subject is election_question" do
    let(:action_subject) { :election_question }

    context "when updating" do
      let(:action_name) { :update }

      it_behaves_like "requires an election"
    end

    context "when updating status" do
      let(:action_name) { :update_status }

      it { is_expected.to be false }

      context "when election is published" do
        let(:election) { create(:election, component:, published_at: 2.days.ago) }

        it { is_expected.to be false }

        context "when questions exist" do
          before { create(:election_question, election:) }

          it { is_expected.to be true }
        end
      end
    end

    context "when reordering" do
      let(:action_name) { :reorder }

      it_behaves_like "requires an election"
    end
  end

  context "when subject is census" do
    let(:action_subject) { :census }

    context "when editing" do
      let(:action_name) { :edit }

      it { is_expected.to be true }
    end

    context "when updating" do
      let(:action_name) { :update }

      it_behaves_like "requires an election"
    end
  end
end
