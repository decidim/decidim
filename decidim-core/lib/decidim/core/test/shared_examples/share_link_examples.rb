# frozen_string_literal: true

shared_examples "share link" do
  it "allows copying the share link from the share modal" do
    expect(page).to have_css(".share-link", text: "Share")
    find(".share-link", text: "Share").click

    # This overrides document.execCommand in order to ensure it was called.
    page.execute_script(
      <<~JS
        var origExec = document.execCommand;
        document.execCommand = function(cmd) {
          if (cmd === "copy") {
            var $test = $('<div id="urlShareTest" />');
            $("#urlShare").append($test);

            var selObj = window.getSelection();
            $test.text(
              "The following text was copied to clipboard: " + selObj.toString()
            );
          } else {
            return Reflect.apply(origExec, document, arguments)
          }
        };
      JS
    )

    within "#socialShare" do
      expect(page).to have_content("Share:")
      expect(page).to have_content("Share link")

      find("a[data-open='urlShare']").click
    end

    within "#urlShare" do
      expect(page).to have_content("Share link:")
      find("button[data-clipboard-copy]").click

      input = find("#urlShareLink")
      expect(page).to have_content("The following text was copied to clipboard: #{input.value}")
    end
  end
end
