# frozen_string_literal: true

shared_examples "share link" do
  it "allows copying the share link from the share modal" do
    click_button("Share")

    # This overrides document.execCommand in order to ensure it was called.
    page.execute_script(
      <<~JS
        var origExec = document.execCommand;
        document.execCommand = function(cmd) {
          if (cmd === "copy") {
            var $test = $('<div id="urlShareTest" />');
            $("#socialShare").append($test);

            var selObj = window.getSelection();
            $test.text(
              "The following text was copied to clipboard: " + selObj.toString()
            );
            return true;
          } else {
            return Reflect.apply(origExec, document, arguments)
          }
        };
      JS
    )

    within "#socialShare" do
      expect(page).to have_content("Share")
      expect(page).to have_content("Copy")

      input = find("#urlShareLink")

      find("[data-clipboard-copy]").click

      expect(find("[data-clipboard-copy]")).to have_content("Copied!")
      expect(page).to have_content("The following text was copied to clipboard: #{input.value}")

      # Check that the screen reader announcement is properly added.
      expect(find("[aria-role='alert']")).to have_content("The link was successfully copied to clipboard.")
    end
  end
end
