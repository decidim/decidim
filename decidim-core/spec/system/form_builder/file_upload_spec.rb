# frozen_string_literal: true

require "spec_helper"

describe "File upload" do
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

  let(:html_document) do
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

          #{javascript_pack_tag "decidim_core", defer: false}
        </body>
        </html>
      HTML
    end
  end
  let(:html_body) { "" }

  let(:form_class) do
    Class.new(Decidim::Form) do
      include Decidim::AttachmentAttributes

      attachments_attribute :image
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
          <div class="image">
            <span data-blob="#{image["file"]}">
              #{image["title"]}
            </span>
          </div>
        HTML
      end

      private

      def image
        @image ||= params.dig(:form, :add_image)
      end
    end
  end

  before do
    switch_to_host(organization.host)
    sign_in current_user

    endpoint = controller.action(:endpoint)
    final_html = html_document
    Rails.application.routes.draw do
      get "/favicon.ico", to: ->(_) { [200, {}, [""]] }
      get "/offline", to: ->(_) { [200, {}, [""]] }
      scope ActiveStorage.routes_prefix do
        get "/disk/:encoded_key/*filename" => "active_storage/disk#show", :as => :rails_disk_service
        put "/disk/:encoded_token" => "active_storage/disk#update", :as => :update_rails_disk_service
        post "/direct_uploads" => "active_storage/direct_uploads#create", :as => :rails_direct_uploads
      end

      post "upload_validations" => "decidim/upload_validations#create", :as => :upload_validations
      get "test_form", to: ->(_) { [200, {}, [final_html]] }
      post "endpoint", to: endpoint
    end

    visit "/test_form"
  end

  after do
    expect_no_js_errors

    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  context "with a single titled file" do
    let(:html_body) do
      record = form
      template.instance_eval do
        decidim_form_for(record, url: "/endpoint") do |builder|
          <<~HTML.strip.html_safe
            #{builder.attachment(
              :image,
              titled: true,
              multiple: false,
              label: "Image",
              button_label: "Add image",
              button_edit_label: "Edit image",
              button_class: "button button__lg button__transparent-secondary w-full"
            )}
            <button type="submit" class="button">Submit</button>
          HTML
        end
      end
    end

    it "does not raise an exception when posting the form" do
      dynamically_attach_file(:form_image, Decidim::Dev.asset("Exampledocument.pdf"), title: "Example doc")

      click_on "Submit"

      within "h1" do
        expect(page).to have_content("Form submitted successfully")
      end
      within "[data-blob]" do
        expect(page).to have_content("Example doc")
      end
    end
  end
end
