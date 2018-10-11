# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLogger do
  subject { described_class.log(action, user, resource, version_id, extra) }

  let(:organization) { create :organization }
  let(:version_id) { 1 }
  let(:extra) { {} }
  let(:user) { create :user, organization: organization, current_sign_in_ip: "127.0.0.1" }
  let(:participatory_space) { create :participatory_process, organization: organization }
  let(:component) { create :component, participatory_space: participatory_space }
  let(:resource) { create :dummy_resource, component: component }
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

    context "when setting its visibility" do
      context "when nothing is set" do
        let(:extra) { {} }

        it "sets it to admin-only" do
          subject
          expect(action_log.visibility).to eq("admin-only")
        end
      end

      context "when setting it" do
        let(:extra) { { visibility: "public-only" } }

        it "sets it" do
          subject
          expect(action_log.visibility).to eq("public-only")
        end
      end
    end

    context "when the action is on a component resource" do
      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq resource
        expect(action_log.component).to eq component
        expect(action_log.participatory_space).to eq participatory_space
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["component"]).not_to be_empty
        expect(action_log.extra["component"]["title"]).not_to be_empty
        expect(action_log.extra["component"]["manifest_name"]).not_to be_empty
        expect(action_log.extra["participatory_space"]).not_to be_empty
        expect(action_log.extra["participatory_space"]["title"]).not_to be_empty
        expect(action_log.extra["participatory_space"]["manifest_name"]).not_to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end

    context "when the action is on a component" do
      let(:resource) { component }

      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq component
        expect(action_log.component).to be_nil
        expect(action_log.participatory_space).to eq participatory_space
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["component"]).to be_empty
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
        expect(action_log.component).to be_nil
        expect(action_log.participatory_space).to be_nil
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["component"]).to be_empty
        expect(action_log.extra["participatory_space"]).to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end

    context "when the action is on another resource" do
      let(:resource) { create(:user, organization: organization) }

      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq resource
        expect(action_log.component).to be_nil
        expect(action_log.participatory_space).to be_nil
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.extra["component"]).to be_empty
        expect(action_log.extra["participatory_space"]).to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end
  end
end
