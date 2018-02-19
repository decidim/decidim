# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLogger do
  subject { described_class.log(action, user, resource, extra) }

  let(:organization) { create :organization }
  let(:extra) { {} }
  let(:user) { create :user, organization: organization, current_sign_in_ip: "127.0.0.1" }
  let(:participatory_space) { create :participatory_process, organization: organization }
  let(:feature) { create :feature, participatory_space: participatory_space }
  let(:resource) { create :dummy_resource, feature: feature }
  let(:action) { "create" }
  let(:action_log) { Decidim::ActionLog.last }

  describe "#log" do
    it "saves the user info" do
      subject
      expect(action_log.extra["user"]["ip"]).to be_present
      expect(action_log.extra["user"]["name"]).to eq user.name
      expect(action_log.extra["user"]["nickname"]).to eq user.nickname
    end

    context "when adding extra data" do
      let(:extra) { { "a" => 1 } }

      it "sets the `extra` field" do
        subject
        expect(action_log.extra["a"]).to eq 1
      end
    end

    context "when the action is on a component resource" do
      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq resource
        expect(action_log.feature).to eq feature
        expect(action_log.participatory_space).to eq participatory_space
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["feature"]).not_to be_empty
        expect(action_log.extra["feature"]["title"]).not_to be_empty
        expect(action_log.extra["feature"]["manifest_name"]).not_to be_empty
        expect(action_log.extra["participatory_space"]).not_to be_empty
        expect(action_log.extra["participatory_space"]["title"]).not_to be_empty
        expect(action_log.extra["participatory_space"]["manifest_name"]).not_to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end

    context "when the action is on a component" do
      let(:resource) { feature }

      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq feature
        expect(action_log.feature).to be_nil
        expect(action_log.participatory_space).to eq participatory_space
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["feature"]).to be_empty
        expect(action_log.extra["participatory_space"]).not_to be_empty
        expect(action_log.extra["participatory_space"]["title"]).not_to be_empty
        expect(action_log.extra["participatory_space"]["manifest_name"]).to be_present
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end

    context "when the action is on a participatory space" do
      let(:resource) { participatory_space }

      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq participatory_space
        expect(action_log.feature).to be_nil
        expect(action_log.participatory_space).to be_nil
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["feature"]).to be_empty
        expect(action_log.extra["participatory_space"]).to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end

    context "when the action is on another resource" do
      let(:resource) { create(:user, organization: organization) }

      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq resource
        expect(action_log.feature).to be_nil
        expect(action_log.participatory_space).to be_nil
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["feature"]).to be_empty
        expect(action_log.extra["participatory_space"]).to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end
  end
end
