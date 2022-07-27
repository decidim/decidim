# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: }
  let(:organization) { create :organization }
  let(:consultation) { create :consultation, organization: }
  let(:question) { create :question, consultation: }
  let(:context) { { consultation:, question: }.merge(extra_context) }
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
    let(:user) { create :user, organization: }
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it { is_expected.to be false }
  end

  describe "consultations" do
    let(:action_subject) { :consultation }

    context "when creating a consultation" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading a consultation" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end

    context "when updating a consultation" do
      let(:action_name) { :update }

      context "when consultation is present" do
        it { is_expected.to be true }
      end

      context "when consultation is not present" do
        let(:consultation) { nil }
        let(:question) { nil }

        it { is_expected.to be false }
      end
    end

    context "when previewing a consultation" do
      let(:action_name) { :preview }

      context "when consultation is present" do
        it { is_expected.to be true }
      end

      context "when consultation is not present" do
        let(:consultation) { nil }
        let(:question) { nil }

        it { is_expected.to be false }
      end
    end

    context "when publishing results of a consultation" do
      let(:action_name) { :publish_results }

      context "when consultation is not finished" do
        let(:consultation) { create :consultation, :active, organization: }

        it { is_expected.to be false }
      end

      context "when consultation is finished and results not published" do
        let(:consultation) { create :consultation, :finished, :unpublished_results, organization: }

        it { is_expected.to be true }
      end

      context "when consultation is finished and results published" do
        let(:consultation) { create :consultation, :finished, :published_results, organization: }

        it { is_expected.to be false }
      end
    end

    context "when unpublishing results of a consultation" do
      let(:action_name) { :unpublish_results }

      context "when results are not published" do
        let(:consultation) { create :consultation, :unpublished_results, organization: }

        it { is_expected.to be false }
      end

      context "when results are published" do
        let(:consultation) { create :consultation, :published_results, organization: }

        it { is_expected.to be true }
      end
    end
  end

  describe "questions" do
    let(:action_subject) { :question }

    context "when creating a question" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading a question" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end

    context "when updating a question" do
      let(:action_name) { :update }

      context "when question is present" do
        it { is_expected.to be true }
      end

      context "when question is not present" do
        let(:question) { nil }

        it { is_expected.to be false }
      end
    end

    context "when destroying a question" do
      let(:action_name) { :destroy }

      context "when question is present" do
        it { is_expected.to be true }
      end

      context "when question is not present" do
        let(:question) { nil }

        it { is_expected.to be false }
      end
    end

    context "when previewing a question" do
      let(:action_name) { :preview }

      context "when question is present" do
        it { is_expected.to be true }
      end

      context "when question is not present" do
        let(:question) { nil }

        it { is_expected.to be false }
      end
    end

    context "when publishing a question" do
      let(:action_name) { :publish }

      context "when question has external voting" do
        let(:question) { create :question, :external_voting, consultation: }

        it { is_expected.to be true }
      end

      context "when question has some responses" do
        let!(:response) { create :response, question: }

        it { is_expected.to be true }
      end

      context "when conditions are not met" do
        it { is_expected.to be false }
      end
    end
  end

  describe "responses" do
    let(:action_subject) { :response }
    let!(:response) { create :response, question: }
    let(:extra_context) { { response: } }

    context "when creating a response" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading a response" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end

    context "when updating a response" do
      let(:action_name) { :update }

      context "when response is present" do
        it { is_expected.to be true }
      end

      context "when response is not present" do
        let(:response) { nil }

        it { is_expected.to be false }
      end
    end

    context "when destroying a response" do
      let(:action_name) { :destroy }

      context "when response is present" do
        it { is_expected.to be true }
      end

      context "when response is not present" do
        let(:response) { nil }

        it { is_expected.to be false }
      end
    end
  end

  describe "response_groups" do
    let(:action_subject) { :response_group }
    let(:question) { create :question, :multiple, consultation: }
    let!(:response_group) { create :response_group, question: }
    let(:extra_context) { { response_group: } }

    context "when creating a response_group" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading a response_group" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end

    context "when updating a response_group" do
      let(:action_name) { :update }

      context "when response_group is present" do
        it { is_expected.to be true }
      end

      context "when response_group is not present" do
        let(:response_group) { nil }

        it { is_expected.to be false }
      end
    end

    context "when destroying a response_group" do
      let(:action_name) { :destroy }

      context "when response_group is present" do
        it { is_expected.to be true }
      end

      context "when response_group is not present" do
        let(:response_group) { nil }

        it { is_expected.to be false }
      end
    end

    context "when question is not multiple" do
      let(:question) { create :question, consultation: }
      let(:action_name) { :create }

      it { is_expected.to be false }
    end
  end

  describe "participatory spaces" do
    let(:action_subject) { :participatory_space }
    let(:action_name) { :read }

    it { is_expected.to be true }
  end

  describe "components" do
    let(:action_subject) { :component }
    let(:action_name) { :manage }
    let(:extra_context) do
      { consultation: nil, participatory_space: question }
    end

    it { is_expected.to be true }
  end
end
