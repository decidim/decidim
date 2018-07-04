# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionAuthorizationHelper do
    let!(:component) { create(:component) }
    let(:user) { create(:user) }
    let(:action) { "foo" }
    let(:authorized) { true }

    before do
      allow(helper).to receive(:current_component).and_return(component)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:action_authorized_to).with(action).and_return(authorized)
      allow(helper).to receive(:action_authorized_to).with(nil).and_return(authorized)
    end

    describe "action_authorized_link_to" do
      context "when the action is authorized" do
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
        let(:authorized) { false }

        it "renders a link toggling the authorization modal" do
          rendered = helper.action_authorized_link_to("foo", "Link", "fake_path")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="authorizationModal"')
          expect(rendered).to include("data-open-url=\"/authorization_modals/foo/f/#{component.id}\"")
          expect(rendered).to include("<a")
        end
      end

      context "when there is not a logged user" do
        let(:user) { nil }

        it "renders a link toggling the login modal" do
          rendered = helper.action_authorized_link_to("foo", "Link", "fake_path")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="loginModal"')
          expect(rendered).to include("<a")
        end
      end
    end

    describe "action_authorized_button_to" do
      context "when the action is authorized" do
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
        let(:authorized) { false }

        it "renders a button toggling the authorization modal" do
          rendered = helper.action_authorized_button_to("foo", "Link", "fake_path")
          expect(rendered).to include("<input")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="authorizationModal"')
          expect(rendered).to include("data-open-url=\"/authorization_modals/foo/f/#{component.id}\"")
        end
      end

      context "when there is not a logged user" do
        let(:user) { nil }

        it "renders a button toggling the login modal" do
          rendered = helper.action_authorized_button_to("foo", "Link", "fake_path")
          expect(rendered).to include("<input")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="loginModal"')
        end
      end
    end

    describe "logged_link_to" do
      context "when there is a logged user" do
        it "renders a regular link" do
          rendered = helper.logged_link_to("Link", "fake_path")
          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<a")
          expect(rendered).to include("Link")
        end

        it "renders with a block" do
          rendered = helper.logged_link_to("fake_path") { "Link" }

          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<a")
          expect(rendered).to include("Link")
        end
      end

      context "when there is not a logged user" do
        let(:user) { nil }

        it "renders a link toggling the login modal" do
          rendered = helper.logged_link_to("Link", "fake_path")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="loginModal"')
          expect(rendered).to include("<a")
        end
      end
    end

    describe "logged_button_to" do
      context "when there is a logged user" do
        it "renders a regular button" do
          rendered = helper.logged_button_to("Link", "fake_path")
          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<input")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).to include("Link")
        end

        it "renders with a block" do
          rendered = helper.logged_button_to("fake_path") { "Link" }

          expect(rendered).not_to include("data-open")
          expect(rendered).to include("<button")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).to include("Link")
        end
      end

      context "when there is not a logged user" do
        let(:user) { nil }

        it "renders a button toggling the login modal" do
          rendered = helper.logged_button_to("Link", "fake_path")
          expect(rendered).to include("<input")
          expect(rendered).to include("type=\"submit\"")
          expect(rendered).not_to include("fake_path")
          expect(rendered).to include('data-open="loginModal"')
        end
      end
    end
  end
end
