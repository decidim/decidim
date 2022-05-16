# frozen_string_literal: true

require "spec_helper"

shared_examples_for "preview component with share_token" do
  context "when component is unpublished" do
    before do
      component.unpublish!
    end

    context "when no share_token is provided" do
      before do
        visit_component
      end

      it "does not allow visiting component" do
        expect(page).to have_content "You are not authorized"
        expect(page.current_path).not_to match main_component_path(component)
      end
    end

    context "when a share_token is provided" do
      let(:share_token) { create(:share_token, token_for: component) }
      let(:params) { { share_token: share_token.token } }

      before do
        uri = URI(main_component_path(component))
        uri.query = URI.encode_www_form(params.to_a)
        visit uri
      end

      context "when a valid share_token is provided" do
        it "allows visiting component" do
          expect(page).not_to have_content "You are not authorized"
          expect(page.current_path).to match main_component_path(component)
        end
      end

      context "when an invalid share_token is provided" do
        let(:share_token) { create(:share_token, :expired, token_for: component) }

        it "does not allow visiting component" do
          expect(page).to have_content "You are not authorized"
          expect(page.current_path).not_to match main_component_path(component)
        end
      end
    end
  end
end
