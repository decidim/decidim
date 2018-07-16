# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionAuthorizationHelper do
    let(:component) { create(:component) }
    let(:resource) { nil }
    let(:user) { create(:user) }
    let(:action) { "foo" }
    let(:status) { double(ok?: authorized) }
    let(:authorized) { true }

    let(:widget_text) { "Link" }
    let(:path) { "fake_path" }

    before do
      allow(helper).to receive(:current_component).and_return(component)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:action_authorized_to).with(action, resource: resource).and_return(status)
    end

    shared_examples "an action authorization widget helper" do |params|
      if params[:has_action]
        context "when the action is not authorized" do
          let(:authorized) { false }

          it "renders a widget toggling the authorization modal" do
            is_expected.not_to include(path)
            is_expected.to include('data-open="authorizationModal"')
            is_expected.to include("data-open-url=\"/authorization_modals/#{action}/f/#{component.id}\"")
            is_expected.to include(*params[:widget_parts])
          end

          context "when called with a resource" do
            let(:resource) { create(:dummy_resource, component: component) }

            it "renders a widget toggling the authorization modal" do
              is_expected.not_to include(path)
              is_expected.to include('data-open="authorizationModal"')
              is_expected.to include("data-open-url=\"/authorization_modals/#{action}/f/#{component.id}/#{resource.resource_manifest.name}/#{resource.id}\"")
              is_expected.to include(*params[:widget_parts])
            end
          end
        end

      else
        let(:action) { nil }
      end

      context "when #{params[:has_action] ? "the action is authorized" : "the user is logged"}" do
        it "renders a regular widget" do
          is_expected.not_to include("data-open")
          is_expected.to include(path)
          is_expected.to include(*params[:widget_parts])
        end
      end

      context "when there is not a logged user" do
        let(:user) { nil }

        it "renders a widget toggling the login modal" do
          is_expected.not_to include(path)
          is_expected.to include('data-open="loginModal"')
          is_expected.to include(*params[:widget_parts])
        end
      end
    end

    describe "action_authorized_link_to" do
      context "when called with text" do
        subject(:rendered) { helper.action_authorized_link_to(action, widget_text, path, resource: resource) }

        it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<a)
      end

      context "when called with a block" do
        subject(:rendered) { helper.action_authorized_link_to(action, path, resource: resource) { widget_text } }

        it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<a)
      end
    end

    describe "action_authorized_button_to" do
      context "when called with text" do
        subject(:rendered) { helper.action_authorized_button_to(action, widget_text, path, resource: resource) }

        it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<input type="submit")
      end

      context "when called with a block" do
        subject(:rendered) { helper.action_authorized_button_to(action, path, resource: resource) { widget_text } }

        it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<button type="submit")
      end
    end

    describe "logged_link_to" do
      context "when called with text" do
        subject(:rendered) { helper.logged_link_to(widget_text, path, resource: resource) }

        it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<a)
      end

      context "when called with a block" do
        subject(:rendered) { helper.logged_link_to(path, resource: resource) { widget_text } }

        it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<a)
      end
    end

    describe "logged_button_to" do
      context "when called with text" do
        subject(:rendered) { helper.logged_button_to(widget_text, path, resource: resource) }

        it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<input type="submit")
      end

      context "when called with a block" do
        subject(:rendered) { helper.logged_button_to(path, resource: resource) { widget_text } }

        it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<button type="submit")
      end
    end
  end
end
