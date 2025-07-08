# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLogger do
  subject { described_class.log(action, user, resource, version_id, extra) }

  let(:organization) { create(:organization) }
  let(:version_id) { 1 }
  let(:extra) { {} }
  let(:user) { create(:user, organization:, current_sign_in_ip: "127.0.0.1") }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space:) }
  let(:resource) { create(:dummy_resource, component:) }
  let(:action) { "create" }
  let(:action_log) { Decidim::ActionLog.last }

  describe "#log" do
    it "saves the user info" do
      subject
      expect(action_log.user_id).to eq(user.id)
      expect(action_log.user_type).to eq("Decidim::User")
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
      let(:resource) { create(:user, organization:) }

      it "creates the action log with the correct data for the resource" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)
        expect(action_log.resource).to eq resource
        expect(action_log.component).to be_nil
        expect(action_log.participatory_space).to be_nil
        expect(action_log.user).to eq user
        expect(action_log.action).to eq action
        expect(action_log.scope).to be_nil
        expect(action_log.extra["component"]).to be_empty
        expect(action_log.extra["participatory_space"]).to be_empty
        expect(action_log.extra["resource"]).not_to be_empty
      end
    end

    describe "scope" do
      context "when the resource has scope" do
        it "saves the resource scope" do
          subject
          expect(action_log.scope).to eq resource.scope
        end
      end

      context "when the resource has no scope" do
        let(:resource) { create(:dummy_resource, component:, scope: nil) }

        context "when the space has a scope" do
          let(:participatory_space) { create(:participatory_process, organization:, scope:) }
          let(:scope) { create(:scope, organization:) }

          it "saves the participatory_space scope" do
            subject
            expect(action_log.scope).to eq participatory_space.scope
          end
        end

        context "when the space has no scope" do
          it "does not save any scope" do
            subject
            expect(action_log.scope).to be_nil
          end
        end
      end
    end

    describe "area" do
      context "when the resource has no area" do
        context "when the space has an area" do
          let(:participatory_space) { create(:assembly, organization:, area:) }
          let(:area) { create(:area, organization:) }

          it "saves the participatory_space area" do
            subject
            expect(action_log.area).to eq participatory_space.area
          end
        end

        context "when the space has no area" do
          it "does not save any area" do
            subject
            expect(action_log.area).to be_nil
          end
        end
      end
    end

    context "when the user is an api user" do
      let!(:user) { create(:api_user, organization:, current_sign_in_ip: "127.0.0.1") }

      it "saves the user info" do
        subject
        expect(action_log.user_id).to eq(user.id)
        expect(action_log.user_type).to eq("Decidim::Api::ApiUser")
        expect(action_log.extra["user"]["ip"]).to be_present
        expect(action_log.extra["user"]["name"]).to eq user.name
        expect(action_log.extra["user"]["nickname"]).to eq user.nickname
      end
    end
  end
end
