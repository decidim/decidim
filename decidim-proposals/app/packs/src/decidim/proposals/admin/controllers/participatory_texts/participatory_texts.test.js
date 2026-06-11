/* global jest */
import { Application } from "@hotwired/stimulus"
import ParticipatoryTextsController from "src/decidim/proposals/admin/controllers/participatory_texts/controller";

describe("ParticipatoryTextsController", () => {
  let application = null;
  let form = null;
  let list = null;

  beforeEach(() => {
    application = Application.start();
    application.register("participatory-texts", ParticipatoryTextsController);

    document.body.innerHTML = `
      <form action="/participatory_texts" method="post" data-controller="participatory-texts">
        <ul id="participatory-text"
            data-participatory-texts-target="list"
            data-action="sortupdate->participatory-texts#updatePositions">
          <li id="item-first"><input class="position" type="hidden" value="1"></li>
          <input type="hidden" name="preview_participatory_text[proposals_attributes][0][id]" value="10">
          <li id="item-second"><input class="position" type="hidden" value="2"></li>
          <input type="hidden" name="preview_participatory_text[proposals_attributes][1][id]" value="11">
          <li id="item-third"><input class="position" type="hidden" value="3"></li>
          <input type="hidden" name="preview_participatory_text[proposals_attributes][2][id]" value="12">
        </ul>
        <button name="save_draft" data-action="participatory-texts#saveDraft">Save draft</button>
        <button name="commit">Publish document</button>
      </form>
    `;

    form = document.querySelector("form");
    list = document.querySelector("#participatory-text");

    return new Promise((resolve) => setTimeout(resolve, 0));
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("saveDraft", () => {
    it("submits the form natively with a save_draft hidden input", () => {
      const submitSpy = jest.spyOn(form, "submit").mockImplementation(() => {});

      form.querySelector("button[name='save_draft']").click();

      const hiddenInput = form.querySelector("input[name='save_draft']");
      expect(hiddenInput.type).toBe("hidden");
      expect(hiddenInput.value).toBe("true");
      expect(submitSpy).toHaveBeenCalled();
    });
  });

  describe("updatePositions", () => {
    it("renumbers the position inputs following the list order", () => {
      list.insertBefore(document.querySelector("#item-third"), document.querySelector("#item-first"));

      list.dispatchEvent(new CustomEvent("sortupdate", { bubbles: true }));

      expect(document.querySelector("#item-third input.position").value).toBe("1");
      expect(document.querySelector("#item-first input.position").value).toBe("2");
      expect(document.querySelector("#item-second input.position").value).toBe("3");
    });

    it("ignores list items without a position input", () => {
      document.querySelector("#item-second input.position").remove();

      expect(() => list.dispatchEvent(new CustomEvent("sortupdate", { bubbles: true }))).not.toThrow();
      expect(document.querySelector("#item-first input.position").value).toBe("1");
      expect(document.querySelector("#item-third input.position").value).toBe("3");
    });
  });
});
