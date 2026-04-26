# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationFormHelper do
    let(:record) do
      DummyAuthorizationHandler.new({})
    end

    describe "authorization_form_for" do
      it "creates form" do
        authorizations_path = helper.decidim_verifications.authorizations_path
        options = {
          builder: AuthorizationFormBuilder,
          as: "authorization_handler",
          url: authorizations_path
        }

        expect(helper).to receive(:decidim_form_for).with(record, options)

        helper.authorization_form_for(record) do
          # empty block to invoke the helper
        end
      end

      it "allows custom options" do
        authorizations_path = helper.decidim_verifications.authorizations_path
        options = {
          builder: AuthorizationFormBuilder,
          as: "authorization_handler",
          url: authorizations_path,
          html: {
            class: "custom_form"
          }
        }

        expect(helper).to receive(:decidim_form_for).with(record, options)

        helper.authorization_form_for(record, html: { class: "custom_form" }) do
          # empty block to invoke the helper
        end
      end
    end
  end
end
