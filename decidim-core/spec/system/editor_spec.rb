# frozen_string_literal: true

require "spec_helper"

describe "Editor", type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: }

  let(:record) { OpenStruct.new(body: "") }
  let(:form) { Decidim::FormBuilder.new(:record, record, template, {}) }
  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end
  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

  let(:html_document) do
    js_configs = {
      messages: {
        editor: I18n.t("editor"),
        selfxssWarning: I18n.t("decidim.security.selfxss_warning")
      }
    }
    editor_wrapper = form.editor(:body, image_upload: { redesigned: true })
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Editor Test</title>
          #{stylesheet_pack_tag "redesigned_decidim_core", media: "all"}
          #{stylesheet_pack_tag "decidim_editor", media: "all"}
        </head>
        <body>
          <header>
            <a href="#content">Skip to main content</a>
          </header>
          <div data-content>
            <main class="layout-1col">
              <div class="cols-6">
                <div class="text-center py-12">
                  <h1 class="h1 decorator inline-block text-left">Editor test</h1>
                </div>
                <div class="page__container">
                  #{editor_wrapper}
                </div>
              </div>
            </main>
          </div>
          <footer>Decidim</footer>
          #{javascript_pack_tag "redesigned_decidim_core", defer: false}
          #{javascript_pack_tag "decidim_editor", defer: false}
          <script>
            Decidim.config.set(#{js_configs.to_json});
          </script>
        </body>
        </html>
      HTML
    end
  end

  let(:input) { find(".editor input[name='record[body]']", visible: :hidden) }
  let(:toolbar) { find(".editor .editor-toolbar") }
  let(:prosemirror) { find(".editor .editor-input .ProseMirror") }

  before do
    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      mount Decidim::Core::Engine => "/"

      post "/direct_uploads" => "active_storage/direct_uploads#create", as: :rails_direct_uploads
      get "test_editor", to: ->(_) { [200, {}, [final_html]] }
    end

    # Login needed for uploading the images
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit "/test_editor"

    # Wait for the editor to be initialized
    expect(page).to have_css(".editor .editor-input .ProseMirror")
  end

  after do
    expect_no_js_errors

    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  it_behaves_like "accessible page"

  context "with basic toolbar controls" do
    before do
      prosemirror.native.send_keys "Hello, world!", [:enter], "Another paragraph."
      prosemirror.native.send_keys [:shift, *Array.new(10).map { :left }]
    end

    it "heading" do
      prosemirror.native.send_keys :up
      %w(2 3 4 5 6).each do |level|
        tag = "h#{level}"
        select_control("heading", level)
        expect_value(
          <<~HTML
            <#{tag}>Hello, world!</#{tag}>
            <p>Another paragraph.</p>
          HTML
        )
      end

      select_control("heading", "normal")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "bold" do
      click_toggle("bold")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <strong>paragraph.</strong></p>
        HTML
      )

      click_toggle("bold")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "italic" do
      click_toggle("italic")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <em>paragraph.</em></p>
        HTML
      )

      click_toggle("italic")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "underline" do
      click_toggle("underline")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <u>paragraph.</u></p>
        HTML
      )

      click_toggle("underline")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "hardBreak" do
      click_toggle("hardBreak")
      prosemirror.native.send_keys "New line"
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <br>New line</p>
        HTML
      )
    end

    it "orderedList" do
      click_toggle("orderedList")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <ol><li><p>Another paragraph.</p></li></ol>
        HTML
      )

      click_toggle("orderedList")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "bulletList" do
      click_toggle("bulletList")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <ul><li><p>Another paragraph.</p></li></ul>
        HTML
      )

      click_toggle("bulletList")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "link" do
      click_toggle("link")
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Link URL", with: "https://decidim.org"
        select "New tab", from: "Target"
        find("button[data-action='save']").click
      end
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <a target="_blank" rel="noopener noreferrer nofollow" href="https://decidim.org">paragraph.</a></p>
        HTML
      )

      click_toggle("link")
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Link URL", with: "https://docs.decidim.org"
        select "Default (same tab)", from: "Target"
        find("button[data-action='save']").click
      end
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <a rel="noopener noreferrer nofollow" href="https://docs.decidim.org">paragraph.</a></p>
        HTML
      )

      click_toggle("link")
      within "[data-dialog][aria-hidden='false']" do
        find("button[data-action='remove']").click
      end
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "common:eraseStyles" do
      click_toggle("bold")
      click_toggle("italic")
      click_toggle("underline")
      click_toggle("orderedList")
      click_toggle("link")
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Link URL", with: "https://decidim.org"
        select "New tab", from: "Target"
        find("button[data-action='save']").click
      end

      click_toggle("common:eraseStyles")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "codeBlock" do
      click_toggle("codeBlock")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <pre><code class="code-block">Another paragraph.</code></pre>
        HTML
      )

      click_toggle("codeBlock")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "blockquote" do
      click_toggle("blockquote")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <blockquote><p>Another paragraph.</p></blockquote>
        HTML
      )

      click_toggle("blockquote")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end

    it "indent:indent and indent:outdent" do
      click_toggle("indent:indent")
      click_toggle("indent:indent")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p class="editor-indent-2">Another paragraph.</p>
        HTML
      )

      click_toggle("indent:outdent")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p class="editor-indent-1">Another paragraph.</p>
        HTML
      )

      click_toggle("indent:outdent")
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another paragraph.</p>
        HTML
      )
    end
  end

  context "with keyboard" do
    context "with tab" do
      it "indents the content at the beginning of the line" do
        prosemirror.native.send_keys "Hello, world!"
        prosemirror.native.send_keys(*Array.new(13).map { :left })
        prosemirror.native.send_keys :tab, :tab
        expect_value('<p class="editor-indent-2">Hello, world!</p>')

        prosemirror.native.send_keys [:shift, :tab]
        expect_value('<p class="editor-indent-1">Hello, world!</p>')

        prosemirror.native.send_keys [:shift, :tab]
        expect_value("<p>Hello, world!</p>")
      end
    end
  end

  context "with markdown shortcuts" do
    it "creates a heading level 2" do
      prosemirror.native.send_keys "## Hello, world!"
      expect_value("<h2>Hello, world!</h2>")
    end

    it "creates a heading level 3" do
      prosemirror.native.send_keys "### Hello, world!"
      expect_value("<h3>Hello, world!</h3>")
    end

    it "creates a heading level 4" do
      prosemirror.native.send_keys "#### Hello, world!"
      expect_value("<h4>Hello, world!</h4>")
    end

    it "creates a heading level 5" do
      prosemirror.native.send_keys "##### Hello, world!"
      expect_value("<h5>Hello, world!</h5>")
    end

    it "creates a heading level 6" do
      prosemirror.native.send_keys "###### Hello, world!"
      expect_value("<h6>Hello, world!</h6>")
    end

    it "creates a bold text" do
      prosemirror.native.send_keys "**Hello, world!**"
      expect_value("<p><strong>Hello, world!</strong></p>")
    end

    it "creates an italic text" do
      prosemirror.native.send_keys "*Hello, world!*"
      expect_value("<p><em>Hello, world!</em></p>")
    end

    it "creates a blockquote" do
      prosemirror.native.send_keys "> Hello, world!"
      expect_value("<blockquote><p>Hello, world!</p></blockquote>")
    end
  end

  def expect_value(html)
    expect(input.value).to eq(html.strip.gsub(/\n/, ""))
  end

  def click_toggle(type)
    within toolbar do
      find("button[data-editor-type='#{type}']").click
    end
  end

  def select_control(type, value)
    within toolbar do
      find("select[data-editor-type='#{type}']").find("option[value='#{value}']").select_option
    end
  end
end
