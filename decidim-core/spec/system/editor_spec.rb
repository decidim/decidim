# frozen_string_literal: true

require "spec_helper"

describe "Editor", type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: }

  # Which features to enable for the toolbar: basic|full
  let(:features) { "basic" }

  let(:redesigned) { true }
  let(:editor_content) { "" }
  let(:editor_options) { {} }
  let(:record) { OpenStruct.new(body: editor_content) }
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
    editor_wrapper = form.editor(:body, toolbar: features, image_upload: { redesigned: }, **editor_options)
    pack_prefix = ""
    content_wrapper = ""
    if redesigned
      pack_prefix = "redesigned_"
      content_wrapper = <<~HTML
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
      HTML
    else
      content_wrapper = <<~HTML
        <main id="content">
          <div class="wrapper">
            <div class="row column">
              <div class="page-title-wrapper">
                <h1 class="heading1 page-title">Editor test</h1>
              </div>
              <div class="columns small-12">
                <div class="card">
                  <div class="card__content">
                    #{editor_wrapper}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      HTML
    end
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Editor Test</title>
          <!--
            The CSRF token has to exist on the page for the image uploads to
            work but the value does not matter as we are disabling the forgery
            protection.
          -->
          <meta name="csrf-token" content="abcdef0123456789">
          #{stylesheet_pack_tag "#{pack_prefix}decidim_core", media: "all"}
          #{stylesheet_pack_tag "decidim_editor", media: "all"}
        </head>
        <body>
          <header>
            <a href="#content">Skip to main content</a>
          </header>
          #{content_wrapper}
          <footer>Decidim</footer>
          #{javascript_pack_tag "#{pack_prefix}decidim_core", defer: false}
          #{javascript_pack_tag "decidim_editor", defer: false}
          <script>
            Decidim.config.set(#{js_configs.to_json});
          </script>
        </body>
        </html>
      HTML
    end
  end

  # Element helpers for the tests
  let(:prosemirror_selector) { ".editor .editor-input .ProseMirror" }
  let(:input) { find(".editor input[name='record[body]']", visible: :hidden) }
  let(:toolbar) { find(".editor .editor-toolbar") }
  let(:prosemirror) { find(prosemirror_selector) }

  before do
    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      # Core routes for the image uploads and API
      mount Decidim::Core::Engine => "/"

      # Necessary ActiveStorage routes for the image uploads and displaying user
      # avatars through the API
      scope ActiveStorage.routes_prefix do
        get "/blobs/redirect/:signed_id/*filename" => "active_storage/blobs/redirect#show", as: :rails_service_blob
        get "/representations/redirect/:signed_blob_id/:variation_key/*filename" => "active_storage/representations/redirect#show", as: :rails_blob_representation
        get "/disk/:encoded_key/*filename" => "active_storage/disk#show", as: :rails_disk_service
        post "/direct_uploads" => "active_storage/direct_uploads#create", as: :rails_direct_uploads
      end
      direct :rails_representation do |representation, options|
        signed_blob_id = representation.blob.signed_id
        variation_key = representation.variation.key
        filename = representation.blob.filename

        route_for(:rails_blob_representation, signed_blob_id, variation_key, filename, options)
      end
      direct :rails_blob do |blob, options|
        route_for(ActiveStorage.resolve_model_to_route, blob, options)
      end
      direct :rails_storage_redirect do |model, options|
        route_for(:rails_service_blob, model.signed_id, model.filename, options)
      end

      # The actual editor testing route for these specs
      get "test_editor", to: ->(_) { [200, {}, [final_html]] }
    end

    # Login needed for uploading the images
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit "/test_editor"

    # Wait for the editor to be initialized
    expect(page).to have_css(prosemirror_selector)
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
          <p>Another <a target="_blank" href="https://decidim.org">paragraph.</a></p>
        HTML
      )

      within prosemirror_selector do
        find("a").double_click
      end
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Link URL", with: "https://docs.decidim.org"
        select "Default (same tab)", from: "Target"
        find("button[data-action='save']").click
      end
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <a href="https://docs.decidim.org">paragraph.</a></p>
        HTML
      )

      # Test that editing works also when re-clicking the link toolbar button
      click_toggle("link")
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Link URL", with: "https://try.decidim.org"
        select "New tab", from: "Target"
        find("button[data-action='save']").click
      end
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <p>Another <a target="_blank" href="https://try.decidim.org">paragraph.</a></p>
        HTML
      )

      click_toggle("common:eraseStyles")
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
          <pre><code>Another paragraph.</code></pre>
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

  context "with full toolbar controls" do
    let(:features) { "full" }

    before do
      prosemirror.native.send_keys "Hello, world!"
    end

    it "videoEmbed" do
      click_toggle("videoEmbed")
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Video URL", with: "https://www.youtube.com/watch?v=f6JMgJAQ2tc"
        fill_in "Title", with: "Decidim"
        find("button[data-action='save']").click
      end

      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
            <div>
              <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
            </div>
          </div>
        HTML
      )

      click_toggle("videoEmbed")
      within "[data-dialog][aria-hidden='false']" do
        fill_in "Video URL", with: "https://www.youtube.com/watch?v=zhMMW0TENNA"
        fill_in "Title", with: "Free Open-Source"
        find("button[data-action='save']").click
      end

      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA">
            <div>
              <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Free Open-Source" frameborder="0" allowfullscreen="true"></iframe>
            </div>
          </div>
        HTML
      )
    end

    it "image" do
      click_toggle("image")
      within "[data-dialog][aria-hidden='false']" do
        add_file("city.jpeg", "[data-dropzone]", "drop")
        fill_in "Alternative text for the image", with: "City landscape"

        within "[data-dialog-actions]" do
          find("button[data-dropzone-save]").click
        end
      end
      expect(Decidim::EditorImage.count).to be(1)

      src = Decidim::EditorImage.last.attached_uploader(:file).path
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <div class="editor-content-image" data-image="">
            <img src="#{src}" alt="City landscape">
          </div>
        HTML
      )
    end

    it "allows adding images through clicking the dropzone" do
      click_toggle("image")
      within "[data-dialog][aria-hidden='false']" do
        add_file("city.jpeg", "[data-dropzone]", "select")
        fill_in "Alternative text for the image", with: "City landscape"

        within "[data-dialog-actions]" do
          find("button[data-dropzone-save]").click
        end
      end
      expect(Decidim::EditorImage.count).to be(1)

      src = Decidim::EditorImage.last.attached_uploader(:file).path
      expect_value(
        <<~HTML
          <p>Hello, world!</p>
          <div class="editor-content-image" data-image="">
            <img src="#{src}" alt="City landscape">
          </div>
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

    context "when managing an ordered list" do
      let(:editor_content) { "<ol><li><p>Item</p></li></ol>" }

      it "allows changing the the list type with ALT+SHIFT+DOWN" do
        %w(a A i I).each do |type|
          prosemirror.native.send_keys [:alt, :shift, :down]
          expect_value(%(<ol type="#{type}" data-type="#{type}"><li><p>Item</p></li></ol>))
        end

        prosemirror.native.send_keys [:alt, :shift, :down]
        expect_value(editor_content)
      end

      it "allows changing the the list type with ALT+SHIFT+UP" do
        %w(I i A a).each do |type|
          prosemirror.native.send_keys [:alt, :shift, :up]
          expect_value(%(<ol type="#{type}" data-type="#{type}"><li><p>Item</p></li></ol>))
        end

        prosemirror.native.send_keys [:alt, :shift, :up]
        expect_value(editor_content)
      end
    end
  end

  context "with clipboard" do
    let(:features) { "full" }

    it "accepts a YouTube video" do
      paste_content("https://www.youtube.com/watch?v=f6JMgJAQ2tc", prosemirror_selector)

      expect_value(
        <<~HTML
          <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
            <div>
              <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="" frameborder="0" allowfullscreen="true"></iframe>
            </div>
          </div>
        HTML
      )
    end

    it "accepts a Vimeo video" do
      paste_content("https://vimeo.com/312909656", prosemirror_selector)

      expect_value(
        <<~HTML
          <div class="editor-content-videoEmbed" data-video-embed="https://vimeo.com/312909656">
            <div>
              <iframe src="https://player.vimeo.com/video/312909656" title="" frameborder="0" allowfullscreen="true"></iframe>
            </div>
          </div>
        HTML
      )
    end

    it "accepts an image" do
      paste_file("city.jpeg", prosemirror_selector)
      expect(Decidim::EditorImage.count).to be(1)

      src = Decidim::EditorImage.last.attached_uploader(:file).path
      expect_value(
        <<~HTML
          <div class="editor-content-image" data-image="">
            <img src="#{src}" alt="city">
          </div>
        HTML
      )
    end

    context "when pasting ordered lists" do
      let(:properly_formatted) do
        <<~HTML
          <ol>
            <li>
              <p><strong>Item 1</strong></p>
              <ol type="a" data-type="a">
                <li><p>Subitem 1.1</p></li>
                <li><p>Subitem 1.2</p></li>
              </ol>
            </li>
            <li>
              <p>Item 2</p>
              <ol type="A" data-type="A">
                <li><p>Subitem 2.1</p></li>
                <li><p>Subitem 2.2</p></li>
              </ol>
            </li>
            <li>
              <p><strong>Item 3</strong></p>
              <ol type="i" data-type="i">
                <li><p>Subitem 3.1</p></li>
                <li><p>Subitem 3.2</p></li>
              </ol>
            </li>
            <li>
              <p>Item 4</p>
              <ol type="I" data-type="I">
                <li><p>Subitem 4.1</p></li>
                <li><p>Subitem 4.2</p></li>
              </ol>
            </li>
          </ol>
        HTML
      end

      # This is to test that the list elements preserve the `type` attribute as
      # this carries information about the ordered list styling and is used by
      # several desktop editors.
      #
      # See: https://github.com/ueberdosis/tiptap/issues/3726
      it "preserves ordered list type and marks inside list elements" do
        paste_content(properly_formatted, prosemirror_selector)
        expect_value(properly_formatted)
      end

      # This is to test the weird markup produced by Google Docs that it is
      # handled properly in the editor.
      #
      # See:
      # https://github.com/ueberdosis/tiptap/issues/3726
      # https://github.com/ueberdosis/tiptap/issues/3735
      it "preserves CSS styled ordered list type and marks" do
        content = <<~HTML
          <b style="font-weight:normal;">
            <ol>
              <li style="list-style-type:decimal;">
                <p><span style="font-weight:700;">Item 1</span></p>
              </li>
              <ol>
                <li style="list-style-type:lower-alpha;font-weight:400;"><p>Subitem 1.1</p></li>
                <li style="list-style-type:lower-alpha;font-weight:normal;"><p>Subitem 1.2</p></li>
              </ol>
              <li style="list-style-type:decimal;">
                <p>Item 2</p>
              </li>
              <ol>
                <li style="list-style-type:upper-alpha;font-weight:400;"><p>Subitem 2.1</p></li>
                <li style="list-style-type:upper-alpha;font-weight:normal;"><p>Subitem 2.2</p></li>
              </ol>
              <li style="list-style-type:decimal;">
                <p><span style="font-weight:bold;">Item 3</span></p>
              </li>
              <ol>
                <li style="list-style-type:lower-roman;font-weight:400;"><p>Subitem 3.1</p></li>
                <li style="list-style-type:lower-roman;font-weight:normal;"><p>Subitem 3.2</p></li>
              </ol>
              <li style="list-style-type:decimal;">
                <p>Item 4</p>
              </li>
              <ol>
                <li style="list-style-type:upper-roman;font-weight:400;"><p>Subitem 4.1</p></li>
                <li style="list-style-type:upper-roman;font-weight:normal;"><p>Subitem 4.2</p></li>
              </ol>
            </ol>
          </b>
        HTML
        paste_content(content, prosemirror_selector)
        expect_value(properly_formatted)
      end
    end
  end

  context "with pointer device" do
    let(:features) { "full" }

    context "when resizing an image" do
      let(:image) { create(:editor_image, organization:) }
      let(:image_src) { image.attached_uploader(:file).path }
      let(:dimensions) { MiniMagick::Image.read(image.file.blob.download).dimensions }
      let(:editor_content) do
        <<~HTML
          <div class="editor-content-image" data-image="">
            <img src="#{image_src}" alt="Test">
          </div>
        HTML
      end

      shared_examples "resize controls" do |mode|
        context "with right side controls" do
          it "allows resizing the image" do
            drag("[data-image-resizer-control='top-right']", mode:, direction: "left", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 100}"></div>))

            drag("[data-image-resizer-control='bottom-right']", mode:, direction: "right", amount: 50)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 50}"></div>))
          end

          it "removes the width attribute when resizing back to original width or above it" do
            drag("[data-image-resizer-control='top-right']", mode:, direction: "left", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 100}"></div>))

            drag("[data-image-resizer-control='bottom-right']", mode:, direction: "right", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test"></div>))

            drag("[data-image-resizer-control='top-right']", mode:, direction: "left", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 100}"></div>))

            drag("[data-image-resizer-control='bottom-right']", mode:, direction: "right", amount: 500)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test"></div>))
          end

          it "shows and updates image sizes" do
            width = dimensions[0]
            height = dimensions[1]

            expect(page).to have_selector("[data-image-resizer-dimension-value='#{width}']", visible: :all)
            expect(page).to have_selector("[data-image-resizer-dimension-value='#{height}']", visible: :all)

            drag("[data-image-resizer-control='top-right']", mode:, direction: "left", amount: 100)
            expect(page).to have_selector("[data-image-resizer-dimension-value='#{width - 100}']", visible: :all)
            expect(page).to have_selector("[data-image-resizer-dimension-value='#{height - 67}']", visible: :all)
          end
        end

        context "with left side controls" do
          it "allows resizing the image" do
            drag("[data-image-resizer-control='bottom-left']", mode:, direction: "right", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 100}"></div>))

            drag("[data-image-resizer-control='top-left']", mode:, direction: "left", amount: 50)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 50}"></div>))
          end

          it "removes the width attribute when resizing back to original width or above it" do
            drag("[data-image-resizer-control='bottom-left']", mode:, direction: "right", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 100}"></div>))

            drag("[data-image-resizer-control='top-left']", mode:, direction: "left", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test"></div>))

            drag("[data-image-resizer-control='bottom-left']", mode:, direction: "right", amount: 100)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test" width="#{dimensions[0] - 100}"></div>))

            drag("[data-image-resizer-control='top-left']", mode:, direction: "left", amount: 500)
            expect_value(%(<div class="editor-content-image" data-image=""><img src="#{image_src}" alt="Test"></div>))
          end
        end
      end

      context "when mouse" do
        it_behaves_like "resize controls", "mouse"
      end

      context "when touch" do
        it_behaves_like "resize controls", "touch"
      end
    end

    def drag(selector, mode: "mouse", direction: nil, amount: 0)
      move =
        case direction
        when "left"
          "x -= #{amount}"
        when "right"
          "x += #{amount}"
        when "top"
          "y -= #{amount}"
        when "bottom"
          "y += #{amount}"
        end

      events =
        if mode == "touch"
          <<~JS
            var evStart = new Event("touchstart");
            evStart.touches = [{ pageX: rect.x, pageY: rect.y }];
            var evMove = new Event("touchmove");
            evMove.touches = [{ pageX: x, pageY: y }];

            element.dispatchEvent(evStart);
            document.dispatchEvent(evMove);
            document.dispatchEvent(new Event("touchend"));
          JS
        else
          <<~JS
            element.dispatchEvent(new MouseEvent("mousedown", { clientX: rect.x, clientY: rect.y }));
            document.dispatchEvent(new MouseEvent("mousemove", { clientX: x, clientY: y }));
            document.dispatchEvent(new MouseEvent("mouseup"));
          JS
        end

      page.execute_script(
        <<~JS
          var element = document.querySelector("#{selector}");
          var rect = element.getBoundingClientRect();

          var x = rect.x;
          var y = rect.y;
          #{move};

          #{events}
        JS
      )
    end
  end

  context "with markdown shortcuts" do
    [2, 3, 4, 5, 6].each do |level|
      it "creates a heading level #{level}" do
        tag = "h#{level}"

        prosemirror.native.send_keys "#{"#" * level} Hello, world!"
        expect_value("<#{tag}>Hello, world!</#{tag}>")
      end
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

  context "with hashtags, mentions and emojis" do
    let(:editor_options) { { hashtaggable: true, mentionable: true, emojiable: true } }

    let!(:user1) { create :user, :confirmed, name: "John Doe", nickname: "doe_john", organization: }
    let!(:user2) { create :user, :confirmed, name: "Jon Doe", nickname: "doe_jon", organization: }
    let!(:user3) { create :user, :confirmed, name: "Jane Doe", nickname: "doe_jane", organization: }

    let!(:hashtag1) { create :hashtag, name: "nature", organization: }
    let!(:hashtag2) { create :hashtag, name: "nation", organization: }
    let!(:hashtag3) { create :hashtag, name: "native", organization: }

    it "allows selecting hashtags" do
      prosemirror.native.send_keys "#na"

      expect(page).to have_selector(".editor-suggestions-item", text: "nature")
      expect(page).to have_selector(".editor-suggestions-item", text: "nation")
      expect(page).to have_selector(".editor-suggestions-item", text: "native")

      find(".editor-suggestions-item", text: "nature").click

      expect_value(%(<p><span data-type="hashtag" data-label="#nature">#nature</span> a</p>))
    end

    it "allows selecting mentions" do
      prosemirror.native.send_keys "@doe"

      expect(page).to have_selector(".editor-suggestions-item", text: "@doe_john (John Doe)")
      expect(page).to have_selector(".editor-suggestions-item", text: "@doe_jon (Jon Doe)")
      expect(page).to have_selector(".editor-suggestions-item", text: "@doe_jane (Jane Doe)")

      find(".editor-suggestions-item", text: "@doe_john (John Doe)").click

      expect_value(%(<p><span data-type="mention" data-id="@doe_john" data-label="@doe_john (John Doe)">@doe_john (John Doe)</span> e</p>))
    end

    it "allows selecting emojis" do
      within ".editor-container .editor-input" do
        expect(page).to have_selector(".emoji__container")
        expect(page).to have_selector(".emoji__trigger .emoji__button")
        find(".emoji__trigger .emoji__button").click
      end

      within ".picmo__popupContainer .picmo__picker .picmo__content" do
        categories = page.all(".picmo__emojiCategory")
        within categories[1] do
          click_button "😀"
        end
      end

      expect_value("<p> 😀 </p>")
    end
  end

  context "with character counter" do
    let(:editor_options) { { maxlength: 13 } }

    it "counts the characters" do
      prosemirror.native.send_keys "Hello, w"

      within ".input-character-counter__text" do
        expect(page).to have_content("5 characters left")
      end
    end

    context "when the character limit is reached" do
      before do
        prosemirror.native.send_keys "Hello, world!"
      end

      it "does not allow new paragraph breaks" do
        prosemirror.native.send_keys [:enter]
        expect_value("<p>Hello, world!</p>")
      end
    end
  end

  # Note that the legacy design is necessary to maintain as long as we have
  # the admin panel using the legacy design. This is also why we test that.
  context "with legacy design" do
    let(:redesigned) { false }

    it_behaves_like "accessible page"

    context "with basic toolbar controls" do
      before do
        prosemirror.native.send_keys "Hello, world!", [:enter], "Another paragraph."
        prosemirror.native.send_keys [:shift, *Array.new(10).map { :left }]
      end

      it "link" do
        click_toggle("link")
        within "[data-reveal][aria-hidden='false']" do
          fill_in "Link URL", with: "https://decidim.org"
          select "New tab", from: "Target"
          find("button[data-action='save']").click
        end
        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <p>Another <a target="_blank" href="https://decidim.org">paragraph.</a></p>
          HTML
        )

        within prosemirror_selector do
          find("a").double_click
        end
        within "[data-reveal][aria-hidden='false']" do
          fill_in "Link URL", with: "https://docs.decidim.org"
          select "Default (same tab)", from: "Target"
          find("button[data-action='save']").click
        end
        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <p>Another <a href="https://docs.decidim.org">paragraph.</a></p>
          HTML
        )

        # Test that editing works also when re-clicking the link toolbar button
        click_toggle("link")
        within "[data-reveal][aria-hidden='false']" do
          fill_in "Link URL", with: "https://try.decidim.org"
          select "New tab", from: "Target"
          find("button[data-action='save']").click
        end
        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <p>Another <a target="_blank" href="https://try.decidim.org">paragraph.</a></p>
          HTML
        )

        click_toggle("common:eraseStyles")
        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <p>Another paragraph.</p>
          HTML
        )
      end
    end

    context "with full toolbar controls" do
      let(:features) { "full" }

      before do
        prosemirror.native.send_keys "Hello, world!"
      end

      it "videoEmbed" do
        click_toggle("videoEmbed")
        within "[data-reveal][aria-hidden='false']" do
          fill_in "Video URL", with: "https://www.youtube.com/watch?v=f6JMgJAQ2tc"
          fill_in "Title", with: "Decidim"
          find("button[data-action='save']").click
        end

        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=f6JMgJAQ2tc">
              <div>
                <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc?cc_load_policy=1&amp;modestbranding=1" title="Decidim" frameborder="0" allowfullscreen="true"></iframe>
              </div>
            </div>
          HTML
        )

        click_toggle("videoEmbed")
        within "[data-reveal][aria-hidden='false']" do
          fill_in "Video URL", with: "https://www.youtube.com/watch?v=zhMMW0TENNA"
          fill_in "Title", with: "Free Open-Source"
          find("button[data-action='save']").click
        end

        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <div class="editor-content-videoEmbed" data-video-embed="https://www.youtube.com/watch?v=zhMMW0TENNA">
              <div>
                <iframe src="https://www.youtube-nocookie.com/embed/zhMMW0TENNA?cc_load_policy=1&amp;modestbranding=1" title="Free Open-Source" frameborder="0" allowfullscreen="true"></iframe>
              </div>
            </div>
          HTML
        )
      end

      it "image" do
        click_toggle("image")
        within "[data-reveal][aria-hidden='false']" do
          add_file("city.jpeg", ".dropzone-container .dropzone", "drop")
          fill_in "Alternative text for the image", with: "City landscape"

          find("button.add-file-file").click
        end
        expect(Decidim::EditorImage.count).to be(1)

        src = Decidim::EditorImage.last.attached_uploader(:file).path
        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <div class="editor-content-image" data-image="">
              <img src="#{src}" alt="City landscape">
            </div>
          HTML
        )
      end

      it "allows adding images through clicking the dropzone" do
        click_toggle("image")
        within "[data-reveal][aria-hidden='false']" do
          add_file("city.jpeg", ".dropzone-container .dropzone", "select")
          fill_in "Alternative text for the image", with: "City landscape"

          find("button.add-file-file").click
        end
        expect(Decidim::EditorImage.count).to be(1)

        src = Decidim::EditorImage.last.attached_uploader(:file).path
        expect_value(
          <<~HTML
            <p>Hello, world!</p>
            <div class="editor-content-image" data-image="">
              <img src="#{src}" alt="City landscape">
            </div>
          HTML
        )
      end
    end
  end

  def expect_value(html)
    expect(input.value).to eq(html.strip.gsub(/\n\s*/, ""))
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

  def file_to_frontend(filename)
    filepath = Decidim::Dev.asset(filename)
    mime = MiniMime.lookup_by_filename(filepath).content_type
    encoded = Base64.encode64(File.read(filepath))

    {
      filename:,
      data_url: "data:application/octet-binary;base64,#{encoded.gsub("\n", "")}",
      mime_type: mime
    }
  end

  def add_file(filename, target_selector, event)
    file = file_to_frontend(filename)

    page.execute_script(
      <<~JS
        var dataUrl = "#{file[:data_url]}";
        fetch(dataUrl).then(function(res) { return res.arrayBuffer(); }).then(function (buffer) {
          var file = new File([buffer], "#{filename}", { type: "#{file[:mime_type]}" });
          var dropzone = document.querySelector("#{target_selector}");

          var dt = new DataTransfer();
          dt.items.add(file);

          if ("#{event}" === "drop") {
            var ev = new Event("drop");
            ev.dataTransfer = dt;
            dropzone.dispatchEvent(ev);
          } else {
            // Simulates selecting the file through the browser's file selector
            var input = dropzone.querySelector("input[type='file']");
            input.files = dt.files;
            input.dispatchEvent(new Event("change", { bubbles: true }));
          }
        });
      JS
    )

    # Wait for the file to be uploaded
    if redesigned
      within "[data-dropzone-items]" do
        expect(page).to have_content(filename)
      end
    else
      expect(page).to have_css("img[alt='Uploaded file']")
    end
  end

  def paste_file(filename, target_selector)
    file = file_to_frontend(filename)

    page.execute_script(
      <<~JS
        var dataUrl = "#{file[:data_url]}";
        fetch(dataUrl).then(function(res) { return res.arrayBuffer(); }).then(function (buffer) {
          var file = new File([buffer], "#{filename}", { type: "#{file[:mime_type]}" });

          var dt = new DataTransfer();
          dt.items.add(file);

          var element = document.querySelector("#{target_selector}");
          element.dispatchEvent(new ClipboardEvent("paste", { clipboardData: dt }));
        });
      JS
    )

    # Wait for the file to be uploaded
    sleep 1
  end

  def paste_content(content, target_selector)
    page.execute_script(
      <<~JS
        var dt = new DataTransfer();
        dt.setData("text/html", #{content.to_json});
        dt.setData("text/plain", #{content.to_json});

        var element = document.querySelector("#{target_selector}");
        element.dispatchEvent(new ClipboardEvent("paste", { clipboardData: dt }));
      JS
    )
  end
end
