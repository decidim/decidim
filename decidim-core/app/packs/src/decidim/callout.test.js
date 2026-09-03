import "src/decidim/callout"

describe("callout close button", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div id="flash-messages-container">
        <div class="flash success" data-alert-box role="alert" aria-atomic="true">
          <div class="flash__message">Signed in successfully.</div>
          <button type="button" class="close-button" data-close aria-label="Dismiss">×</button>
        </div>
      </div>
    `;
  });

  it("removes the alert box when the close button is clicked", () => {
    const closeButton = document.querySelector("[data-close]");

    expect(document.querySelector("[data-alert-box]")).not.toBeNull();

    closeButton.click();

    expect(document.querySelector("[data-alert-box]")).toBeNull();
  });

  it("does nothing when clicking outside of the close button", () => {
    const message = document.querySelector(".flash__message");

    message.click();

    expect(document.querySelector("[data-alert-box]")).not.toBeNull();
  });
});
