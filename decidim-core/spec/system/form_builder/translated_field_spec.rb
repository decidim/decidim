# frozen_string_literal: true

require "spec_helper"

describe "Translated field" do
  let(:template_class) do
    Class.new(ActionView::Base) do
      include Decidim::LayoutHelper
      include Decidim::DecidimFormHelper

      def protect_against_forgery?
        false
      end
    end
  end
  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, :admin, organization:) }
  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
  let(:options) { {} }
  let(:available_locales) { %w(en ca es) }

  let(:html_document) do
    js_configs = {
      api_path: "/api",
      messages: {
        editor: I18n.t("editor"),
        selfxssWarning: I18n.t("decidim.security.selfxss_warning"),
        characterCounter: {
          charactersAtLeast: {
            one: I18n.t("forms.length_validator.minimum.one", count: "%count%", default: "forms.length_validator.minimum.other"),
            other: I18n.t("forms.length_validator.minimum.other", count: "%count%")
          },
          charactersLeft: {
            one: I18n.t("decidim.components.add_comment_form.remaining_characters_1", count: "%count%"),
            other: I18n.t("decidim.components.add_comment_form.remaining_characters", count: "%count%")
          }
        }
      }
    }
    document_inner = html_body.html_safe
    template.append_stylesheet_pack_tag("decidim_dev")
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Form Test</title>
          #{stylesheet_pack_tag "decidim_core"}
        </head>
        <body>
          <header>
            <a href="#content">Skip to main content</a>
          </header>
          <main id="content">
            <h1>Form Test</h1>
            <div class="dev__form">
              #{document_inner}
            </div>
          </main>

          #{javascript_pack_tag "decidim_core", "decidim_controllers", defer: false}
          <script>
            Decidim.config.set(#{js_configs.to_json});
            window.isTestEnvironment = true;
          </script>
        </body>
        </html>
      HTML
    end
  end

  let(:form_class) do
    Class.new(Decidim::Form) do
      include Decidim::TranslatableAttributes

      translatable_attribute :text, String
      translatable_attribute :textarea, Decidim::Attributes::RichText
    end
  end
  let(:form) { form_class.new }

  let(:controller) do
    Class.new(Decidim::ApplicationController) do
      def self.name
        "AnonymousController"
      end

      def endpoint
        render html: <<~HTML.html_safe
          <h1>Form submitted successfully</h1>
        HTML
      end
    end
  end

  before do
    I18n.available_locales = available_locales
    Decidim.available_locales = available_locales
    I18n.backend.reload!

    switch_to_host(organization.host)
    sign_in current_user

    endpoint = controller.action(:endpoint)
    final_html = html_document
    Rails.application.routes.draw do
      get "/favicon.ico", to: ->(_) { [200, {}, [""]] }

      get "test_form", to: ->(_) { [200, {}, [final_html]] }
      post "endpoint", to: endpoint
    end
    visit "/test_form"
  end

  after do
    I18n.available_locales = %w(en ca es)
    Decidim.available_locales = %w(en ca es)
    I18n.backend.reload!

    expect_no_js_errors

    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  context "when using dropdowns" do
    let(:available_locales) { %w(en ca es it fr) }

    context "with input field" do
      let(:html_body) do
        form.text_en = "The english"
        form.text_es = "The spanish"

        record = form
        template.instance_eval do
          decidim_form_for(record, url: "/endpoint") do |builder|
            <<~HTML.strip.html_safe
              #{builder.translated(:text_field, :text)}
              <button type="submit" class="button">Submit</button>
            HTML
          end
        end
      end

      it "successfully focuses the field" do
        select "Castellano", from: "form-text-tabs"

        expect(find("input:focus")[:id]).to eq("form_text_es")
      end

      it "successfully moves the cursor at the end" do
        select "Castellano", from: "form-text-tabs"

        cursor_pos = page.evaluate_script("document.getElementById('form_text_es').selectionStart")
        expect(cursor_pos).to eq("The spanish".length)
      end
    end

    context "with editor field" do
      let(:html_body) do
        form.textarea_en = "The english"
        form.textarea_es = "The spanish"

        record = form
        template.instance_eval do
          decidim_form_for(record, url: "/endpoint") do |builder|
            <<~HTML.strip.html_safe
              #{builder.translated(:editor, :textarea)}
              <button type="submit" class="button">Submit</button>
            HTML
          end
        end
      end

      it "successfully focuses the field" do
        select "Castellano", from: "form-textarea-tabs"

        expect(find(id: "form_textarea_es")).to be_visible
      end

      it "successfully moves the cursor at the end" do
        select "Castellano", from: "form-textarea-tabs"

        cursor_pos = page.evaluate_script('Stimulus.getControllerForElementAndIdentifier(document.getElementById("form_textarea_es").querySelector(".editor-container"),"editor").editor.state.selection.from')
        expect(cursor_pos).to eq("The spanish".length + 1)
      end
    end
  end

  context "when using tabs" do
    let(:available_locales) { %w(en ca es) }

    context "with input field" do
      let(:html_body) do
        form.text_en = "The english"
        form.text_es = "The spanish"

        record = form
        template.instance_eval do
          decidim_form_for(record, url: "/endpoint") do |builder|
            <<~HTML.strip.html_safe
              #{builder.translated(:text_field, :text)}
              <button type="submit" class="button">Submit</button>
            HTML
          end
        end
      end

      it "successfully focuses the field" do
        click_on "Castellano"

        expect(find("input:focus")[:id]).to eq("form_text_es")
      end

      it "successfully moves the cursor at the end" do
        click_on "Castellano"

        cursor_pos = page.evaluate_script("document.getElementById('form_text_es').selectionStart")
        expect(cursor_pos).to eq("The spanish".length)
      end
    end

    context "with editor field" do
      let(:html_body) do
        form.textarea_en = "The english"
        form.textarea_es = "The spanish"

        record = form
        template.instance_eval do
          decidim_form_for(record, url: "/endpoint") do |builder|
            <<~HTML.strip.html_safe
              #{builder.translated(:editor, :textarea)}
              <button type="submit" class="button">Submit</button>
            HTML
          end
        end
      end

      it "successfully focuses the field" do
        click_on "Castellano"

        expect(find(id: "form_textarea_es")).to be_visible
      end

      it "successfully moves the cursor at the end" do
        click_on "Castellano"

        cursor_pos = page.evaluate_script('Stimulus.getControllerForElementAndIdentifier(document.getElementById("form_textarea_es").querySelector(".editor-container"),"editor").editor.state.selection.from')
        expect(cursor_pos).to eq("The spanish".length + 1)
      end
    end
  end
end
