# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:consultation) { create :consultation, organization: organization }
  let(:question) { create :question, consultation: consultation }
  let(:context) { { consultation: consultation, question: question }.merge(extra_context) }
  let(:extra_context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  context "when the action is not for the admin part" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    it { is_expected.to eq false }
  end

  describe "consultations" do
    let(:action_subject) { :consultation }

    context "when creating a consultation" do
      let(:action_name) { :create }

      it { is_expected.to eq true }
    end

    context "when reading a consultation" do
      let(:action_name) { :read }

      it { is_expected.to eq true }
    end

    context "when updating a consultation" do
      let(:action_name) { :update }

      context "when consultation is present" do
        it { is_expected.to eq true }
      end

      context "when consultation is not present" do
        let(:consultation) { nil }
        let(:question) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when destroying a consultation" do
      let(:action_name) { :destroy }

      context "when consultation is present" do
        it { is_expected.to eq true }
      end

      context "when consultation is not present" do
        let(:consultation) { nil }
        let(:question) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when previewing a consultation" do
      let(:action_name) { :preview }

      context "when consultation is present" do
        it { is_expected.to eq true }
      end

      context "when consultation is not present" do
        let(:consultation) { nil }
        let(:question) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when publishing results of a consultation" do
      let(:action_name) { :publish_results }

      context "when consultation is not finished" do
        let(:consultation) { create :consultation, :active, organization: organization }

        it { is_expected.to eq false }
      end

      context "when consultation is finished and results not published" do
        let(:consultation) { create :consultation, :finished, :unpublished_results, organization: organization }

        it { is_expected.to eq true }
      end

      context "when consultation is finished and results published" do
        let(:consultation) { create :consultation, :finished, :published_results, organization: organization }

        it { is_expected.to eq false }
      end
    end

    context "when unpublishing results of a consultation" do
      let(:action_name) { :unpublish_results }

      context "when results are not published" do
        let(:consultation) { create :consultation, :unpublished_results, organization: organization }

        it { is_expected.to eq false }
      end

      context "when results are published" do
        let(:consultation) { create :consultation, :published_results, organization: organization }

        it { is_expected.to eq true }
      end
    end
  end

  describe "questions" do
    let(:action_subject) { :question }

    context "when creating a question" do
      let(:action_name) { :create }

      it { is_expected.to eq true }
    end

    context "when reading a question" do
      let(:action_name) { :read }

      it { is_expected.to eq true }
    end

    context "when updating a question" do
      let(:action_name) { :update }

      context "when question is present" do
        it { is_expected.to eq true }
      end

      context "when question is not present" do
        let(:question) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when destroying a question" do
      let(:action_name) { :destroy }

      context "when question is present" do
        it { is_expected.to eq true }
      end

      context "when question is not present" do
        let(:question) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when previewing a question" do
      let(:action_name) { :preview }

      context "when question is present" do
        it { is_expected.to eq true }
      end

      context "when question is not present" do
        let(:question) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when publishing a question" do
      let(:action_name) { :publish }

      context "when question has external voting" do
        let(:question) { create :question, :external_voting, consultation: consultation }

        it { is_expected.to eq true }
      end

      context "when question has some responses" do
        let!(:response) { create :response, question: question }

        it { is_expected.to eq true }
      end

      context "when conditions are not met" do
        it { is_expected.to eq false }
      end
    end
  end

  describe "responses" do
    let(:action_subject) { :response }
    let!(:response) { create :response, question: question }
    let(:extra_context) { { response: response } }

    context "when creating a response" do
      let(:action_name) { :create }

      it { is_expected.to eq true }
    end

    context "when reading a response" do
      let(:action_name) { :read }

      it { is_expected.to eq true }
    end

    context "when updating a response" do
      let(:action_name) { :update }

      context "when response is present" do
        it { is_expected.to eq true }
      end

      context "when response is not present" do
        let(:response) { nil }

        it { is_expected.to eq false }
      end
    end

    context "when destroying a response" do
      let(:action_name) { :destroy }

      context "when response is present" do
        it { is_expected.to eq true }
      end

      context "when response is not present" do
        let(:response) { nil }

        it { is_expected.to eq false }
      end
    end
  end
end
