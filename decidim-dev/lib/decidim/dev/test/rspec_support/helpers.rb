# frozen_string_literal: true

# Helpers that get automatically included in component specs.
module Decidim
  module ComponentTestHelpers
    def click_submenu_link(text)
      within ".secondary-nav--subnav" do
        click_on text
      end
    end

    def within_user_menu
      main_bar_selector = ".main-bar"

      within main_bar_selector do
        find_by_id("trigger-dropdown-account").click

        yield
      end
    end

    def within_admin_sidebar_menu
      within("[id='admin-sidebar-menu-settings']") do
        yield
      end
    end

    def within_admin_menu
      click_on "Manage"
      within("[id*='dropdown-menu-settings']") do
        yield
      end
    end

    def within_language_menu(options = {})
      within(options[:admin] ? ".language-choose" : "footer") do
        find(options[:admin] ? "#admin-menu-trigger" : "#trigger-dropdown-language-chooser").click
        yield
      end
    end

    def stripped(text)
      text.gsub(/^<p>/, "").gsub(%r{</p>$}, "")
    end

    def within_flash_messages
      within ".flash", match: :first do
        yield
      end
    end

    def expect_user_logged
      expect(page).to have_css(".main-bar #trigger-dropdown-account")
    end

    def have_admin_callout(text)
      within_flash_messages do
        have_content text
      end
    end

    def stub_get_request_with_format(rq_url, rs_format)
      stub_request(:get, rq_url)
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "User-Agent" => "Ruby"
          }
        )
        .to_return(status: 200, body: "", headers: { content_type: rs_format })
    end
  end

  module FrontEndDataTestHelpers
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

  module FrontEndPointerTestHelpers
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

    def select_text(selector)
      page.execute_script(
        <<~JS
          var selection = document.getSelection();
          var range = document.createRange();
          var element = document.querySelector("#{selector}");

          range.selectNodeContents(element);
          selection.removeAllRanges();
          selection.addRange(range);
          document.dispatchEvent(new MouseEvent("selectstart"));
          document.dispatchEvent(new MouseEvent("mouseup"));
        JS
      )
    end
  end

  module FrontEndFileTestHelpers
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
      within "[data-dropzone-items]" do
        expect(page).to have_content(filename)
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
  end
end

RSpec.configure do |config|
  config.include Decidim::ComponentTestHelpers, type: :system
end
