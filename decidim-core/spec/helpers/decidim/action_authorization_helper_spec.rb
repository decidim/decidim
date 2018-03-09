# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionAuthorizationHelper do
    let!(:component) { create(:component) }
    let!(:user) { create(:user) }
    let!(:action) { "foo" }

    let(:status) do
      double(
        handler_name: handler_name,
        code: code,
        data: data,
        "ok?": ok?
      )
    end

    let(:ok?) { false }
    let(:code) { :missing }
    let(:handler_name) { "foo_authorization" }
    let(:data) { { action: data_action, fields: data_fields } }
    let(:data_action) { :authorize }
    let(:data_fields) { nil }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:action_authorization).with(action).and_return(status)
    end

    describe "action_authorization_modal" do
      context "when missing" do
        let(:code) { :missing }
        let(:ok?) { false }

        it "renders a modal with the missing information" do
          expect(helper).to receive(:authorize_action_path).with("foo").and_return "authorization_route"
          rendered = helper.action_authorization_modal("foo")
          expect(rendered).to include("missing-authorization")
          expect(rendered).not_to include("expired-authorization")
          expect(rendered).not_to include("incomplete-authorization")
          expect(rendered).not_to include("unauthorized-authorization")
        end
      end

      context "when expired" do
        let(:code) { :expired }
        let(:ok?) { false }

        it "renders a modal with the expired information" do
          expect(helper).to receive(:authorize_action_path).with("foo").and_return "authorization_route"
          rendered = helper.action_authorization_modal("foo")
          expect(rendered).to include("expired-authorization")
          expect(rendered).not_to include("missing-authorization")
          expect(rendered).not_to include("incomplete-authorization")
          expect(rendered).not_to include("unauthorized-authorization")
        end
      end

      context "when incomplete" do
        let(:code) { :incomplete }
        let(:data_action) { :reauthorize }
        let(:data_fields) { %w(foo bar) }
        let(:ok?) { false }

        it "renders a modal with the missing information" do
          expect(helper).to receive(:authorize_action_path).with("foo").and_return "authorization_route"
          rendered = helper.action_authorization_modal("foo")
          expect(rendered.downcase).to include("reauthorize")
          expect(rendered).to include("incomplete-authorization")
          expect(rendered).not_to include("expired-authorization")
          expect(rendered).not_to include("missing-authorization")
          expect(rendered).not_to include("unauthorized-authorization")
        end
      end

      context "when unauthorized" do
        let(:code) { :unauthorized }
        let(:data_action) { nil }
        let(:data_fields) { %w(foo bar) }
        let(:ok?) { false }

        it "renders a modal with the unauthorized information" do
          rendered = helper.action_authorization_modal("foo")
          expect(rendered).to include("unauthorized-authorization")
          expect(rendered).not_to include("expired-authorization")
          expect(rendered).not_to include("missing-authorization")
          expect(rendered).not_to include("incomplete-authorization")
        end
      end

      context "when ok" do
        let(:code) { :ok }
        let(:ok?) { true }

        it "renders blank" do
          expect(helper.action_authorization_modal("foo")).to be_blank
        end
      end
    end

    describe "action_authorized_link_to" do
      context "when the action is authorized" do
        let(:code) { :ok }
        let(:ok?) { true }

        it "renders a regular link" do
          rendered = helper.action_authorized_link_to("foo", "Link", "fake_path")
          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<a")
          expect(rendered).to include("Link")
        end

        it "renders with a block" do
          rendered = helper.action_authorized_link_to("foo", "fake_path") { "Link" }

          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<a")
          expect(rendered).to include("Link")
        end
      end

      context "when the action is not authorized" do
        let(:code) { :missing }
        let(:ok?) { false }

        it "renders a link toggling the modal" do
          rendered = helper.action_authorized_link_to("foo", "Link", "fake_path")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="fooAuthorizationModal"')
          expect(rendered).to include("<a")
        end
      end
    end

    describe "action_authorized_button_to" do
      context "when the action is authorized" do
        let(:code) { :ok }
        let(:ok?) { true }

        it "renders a regular button" do
          rendered = helper.action_authorized_button_to("foo", "Link", "fake_path")
          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<input")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).to include("Link")
        end

        it "renders with a block" do
          rendered = helper.action_authorized_button_to("foo", "fake_path") { "Link" }

          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<button")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).to include("Link")
        end
      end

      context "when the action is not authorized" do
        let(:code) { :missing }
        let(:ok?) { false }

        it "renders a button toggling the modal" do
          rendered = helper.action_authorized_button_to("foo", "Link", "fake_path")
          expect(rendered).to include("<input")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="fooAuthorizationModal"')
        end
      end
    end
  end
end
