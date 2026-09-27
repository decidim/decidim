import { jest } from "@jest/globals"
import { Application } from "@hotwired/stimulus"
import confirmAction from "src/decidim/confirm"
import UnsavedFormController from "src/decidim/controllers/unsaved_form/controller"

jest.mock("src/decidim/confirm", () => jest.fn(() => Promise.resolve(false)))
jest.mock("src/decidim/refactor/moved/i18n", () => ({ getMessages: () => "Unsaved changes" }))

const markup = (formAttributes = "") => `
  <div class="questionnaire-questions">
    <button type="button" class="add-question">Add question</button>
    <button type="button" class="collapse-all">Collapse all</button>
  </div>
  <form data-controller="unsaved-form" ${formAttributes} id="questionnaire">
    <input name="input name[title]">
    <div class="questionnaire-questions-list" data-draggable-table>
      <div class="card questionnaire-question">
        <button type="button" class="remove-question">Remove</button>
      </div>
    </div>
  </form>
  <form id="other-form">
    <button type="button" class="add-response-option">Add option</button>
  </form>
  <button type="button" class="add-separator" form="other-form">Add separator</button>
  <button type="button" class="add-display-condition" form="questionnaire">Add condition</button>
  <a href="#">Back</a>
  <a href="/filters" data-remote="true">Filter</a>
  <a href="/local-filter" data-remote="false">Local filter</a>
`

const dispatchAjaxComplete = (form, status) => {
  form.dispatchEvent(new CustomEvent("ajax:complete", { bubbles: true, detail: [{ status }] }));
}

const expectUnloadPrompt = (dirty) => {
  const event = new Event("beforeunload", { cancelable: true });
  window.dispatchEvent(event);

  expect(event.defaultPrevented).toBe(dirty);
}

describe("UnsavedFormController", () => {
  let application = null;
  let controller = null;
  let form = null;
  let input = null;
  let link = null;

  const connect = async (formAttributes = "") => {
    if (application) {
      controller.disconnect();
      application.stop();
    }

    document.body.innerHTML = markup(formAttributes);

    application = Application.start();
    application.register("unsaved-form", UnsavedFormController);

    await new Promise((resolve) => setTimeout(resolve, 0));

    form = document.querySelector("form");
    input = form.querySelector("input");
    link = document.querySelector("a");
    controller = application.getControllerForElementAndIdentifier(form, "unsaved-form");
  };

  beforeEach(async () => {
    await connect();
  });

  afterEach(() => {
    controller.disconnect();
    application.stop();
    application = null;
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

  it("does not confirm navigation for remote links, because they request in place", () => {
    input.dispatchEvent(new Event("input", { bubbles: true }));

    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    document.querySelector("a[href='/filters']").dispatchEvent(event);

    expect(event.defaultPrevented).toBe(false);
    expect(confirmAction).not.toHaveBeenCalled();
  });

  it("keeps the form dirty when a confirmed remote link does not navigate", async () => {
    jest.mocked(confirmAction).mockResolvedValueOnce(true);
    input.dispatchEvent(new Event("input", { bubbles: true }));

    document.querySelector("a[href='/filters']").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("confirms navigation for links with a disabled remote flag", () => {
    input.dispatchEvent(new Event("input", { bubbles: true }));
    document.addEventListener("click", (event) => event.preventDefault(), { once: true });

    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    document.querySelector("a[href='/local-filter']").dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
    expect(confirmAction).toHaveBeenCalled();
  });

  it("blocks navigation while the confirmation is pending", () => {
    link.setAttribute("href", "/proposals");
    input.dispatchEvent(new Event("input", { bubbles: true }));

    link.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));
    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    link.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
    expect(confirmAction).toHaveBeenCalledTimes(1);
  });

  it("marks the form dirty when a control outside of it adds content", () => {
    document.querySelector(".add-question").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("marks the form dirty when a control inside of it removes content", () => {
    // The dynamic fields component stops the click from propagating.
    form.querySelector(".questionnaire-questions-list").addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
    });

    form.querySelector(".remove-question").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("does not mark the form dirty when other controls are clicked", () => {
    document.querySelector(".collapse-all").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(controller.dirty).toBe(false);
    expectUnloadPrompt(false);
  });

  it("does not mark the form dirty when a control of another form is clicked", () => {
    document.querySelector("#other-form .add-response-option").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(controller.dirty).toBe(false);
    expectUnloadPrompt(false);
  });

  it("marks the form dirty when a control outside of it is associated through a form attribute", () => {
    document.querySelector(".add-display-condition").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("does not mark the form dirty when a control outside of it is associated to another form", () => {
    document.querySelector("[form=\"other-form\"].add-separator").dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(controller.dirty).toBe(false);
    expectUnloadPrompt(false);
  });

  it("marks the form dirty when its content is reordered", () => {
    form.querySelector(".questionnaire-questions-list").dispatchEvent(new CustomEvent("sortupdate", { detail: {} }));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("allows form submission without an unload prompt", async () => {
    input.dispatchEvent(new Event("input", { bubbles: true }));
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }));
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(controller.dirty).toBe(false);
    expectUnloadPrompt(false);
  });

  it("keeps the form dirty when a later listener prevents the submit", async () => {
    input.dispatchEvent(new Event("input", { bubbles: true }));
    document.addEventListener("submit", (event) => event.preventDefault(), { once: true });

    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }));
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("keeps a remote form dirty until the request succeeds", async () => {
    await connect("data-remote=\"true\"");

    input.dispatchEvent(new Event("input", { bubbles: true }));
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }));
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("does not consider a failed remote request as saved", async () => {
    await connect("data-remote=\"true\"");

    input.dispatchEvent(new Event("input", { bubbles: true }));
    dispatchAjaxComplete(form, 422);

    expect(controller.dirty).toBe(true);
    expectUnloadPrompt(true);
  });

  it("considers a successful remote request as saved", async () => {
    await connect("data-remote=\"true\"");

    input.dispatchEvent(new Event("input", { bubbles: true }));
    dispatchAjaxComplete(form, 200);

    expect(controller.dirty).toBe(false);
    expectUnloadPrompt(false);
  });
});
