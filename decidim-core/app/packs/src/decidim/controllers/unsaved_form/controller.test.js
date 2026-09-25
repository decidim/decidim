import { jest } from "@jest/globals"
import { Application } from "@hotwired/stimulus"
import confirmAction from "src/decidim/confirm"
import UnsavedFormController from "src/decidim/controllers/unsaved_form/controller"

jest.mock("src/decidim/confirm", () => jest.fn(() => Promise.resolve(false)))
jest.mock("src/decidim/refactor/moved/i18n", () => ({ getMessages: () => "Unsaved changes" }))

describe("UnsavedFormController", () => {
  let application = null;
  let controller = null;
  let form = null;
  let input = null;
  let link = null;

  beforeEach(async () => {
    document.body.innerHTML = `
      <form data-controller="unsaved-form">
        <input name="input name[title]">
      </form>
      <a href="#">Back</a>
    `;

    application = Application.start();
    application.register("unsaved-form", UnsavedFormController);

    await new Promise((resolve) => setTimeout(resolve, 0));

    form = document.querySelector("form");
    input = form.querySelector("input");
    link = document.querySelector("a");
    controller = application.getControllerForElementAndIdentifier(form, "unsaved-form");
  });

  afterEach(() => {
    controller.disconnect();
    application.stop();
    jest.clearAllMocks();
  });

  it("does not confirm navigation before the form changes", () => {
    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    link.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(false);
    expect(confirmAction).not.toHaveBeenCalled();
  });

  it("confirms navigation after the form changes", () => {
    link.setAttribute("href", "/proposals");
    input.dispatchEvent(new Event("input", { bubbles: true }));

    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    link.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
    expect(confirmAction).toHaveBeenCalledWith("Unsaved changes", link, { iconName: "alert-line" });
  });

  it("does not confirm navigation for ignored form-flow links", () => {
    link.setAttribute("href", "/proposals");
    link.setAttribute("data-unsaved-form-ignore", "true");
    input.dispatchEvent(new Event("input", { bubbles: true }));
    document.addEventListener("click", (event) => event.preventDefault(), { once: true });

    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    link.dispatchEvent(event);

    expect(confirmAction).not.toHaveBeenCalled();
  });

  it("allows form submission without an unload prompt", () => {
    input.dispatchEvent(new Event("input", { bubbles: true }));
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }));

    const event = new Event("beforeunload", { cancelable: true });
    window.dispatchEvent(event);

    expect(controller.dirty).toBe(false);
    expect(event.defaultPrevented).toBe(false);
  });
});
