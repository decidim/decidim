# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:consultation) { create :consultation, organization: organization }
  let(:question) { create :question, consultation: consultation }
  let(:context) { { consultation: consultation, question: question } }
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

  context "when creating a consultation" do
    let(:action_subject) { :consultation }
    let(:action_name) { :create }

    it { is_expected.to eq true }
  end

  context "when reading a consultation" do
    let(:action_subject) { :consultation }
    let(:action_name) { :read }

    it { is_expected.to eq true }
  end

  context "when updating a consultation" do
    let(:action_subject) { :consultation }
    let(:action_name) { :update }

    context "when consultation is present" do
      it { is_expected.to eq true }
    end

    context "when consultation is not present" do
      let(:consultation) { nil }
      let(:question ) { nil }

      it { is_expected.to eq false }
    end
  end

  context "when destroying a consultation" do
    let(:action_subject) { :consultation }
    let(:action_name) { :destroy }

    context "when consultation is present" do
      it { is_expected.to eq true }
    end

    context "when consultation is not present" do
      let(:consultation) { nil }
      let(:question ) { nil }

      it { is_expected.to eq false }
    end
  end

  context "when previewing a consultation" do
    let(:action_subject) { :consultation }
    let(:action_name) { :preview }

    context "when consultation is present" do
      it { is_expected.to eq true }
    end

    context "when consultation is not present" do
      let(:consultation) { nil }
      let(:question ) { nil }

      it { is_expected.to eq false }
    end
  end

  context "when publishing results of a consultation" do
    let(:action_subject) { :consultation }
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
    let(:action_subject) { :consultation }
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
