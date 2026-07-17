import FocusGuard from "src/decidim/refactor/moved/focus_guard"

describe("FocusGuard", () => {
  let focusGuard;

  beforeEach(() => {
    document.body.innerHTML = "";
    focusGuard = new FocusGuard(document.body);
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  describe("single dialog", () => {
    it("creates focus guards on trap", () => {
      const dialog = document.createElement("div");
      const trigger = document.createElement("button");
      document.body.appendChild(dialog);
      document.body.appendChild(trigger);

      focusGuard.trap(dialog, trigger);
      const guards = document.body.querySelectorAll(".focusguard");
      expect(guards.length).toBe(2);
    });

    it("removes focus guards and returns focus on disable", () => {
      const dialog = document.createElement("div");
      const trigger = document.createElement("button");
      document.body.appendChild(dialog);
      document.body.appendChild(trigger);

      focusGuard.trap(dialog, trigger);
      focusGuard.disable();

      const guards = document.body.querySelectorAll(".focusguard");
      expect(guards.length).toBe(0);
      expect(document.activeElement).toBe(trigger);
    });
  });

  describe("nested dialogs", () => {
    it("keeps guards when inner dialog is disabled", () => {
      const outerDialog = document.createElement("div");
      const outerTrigger = document.createElement("button");
      const innerDialog = document.createElement("div");
      const innerTrigger = document.createElement("button");

      document.body.appendChild(outerDialog);
      document.body.appendChild(outerTrigger);
      document.body.appendChild(innerDialog);
      document.body.appendChild(innerTrigger);

      focusGuard.trap(outerDialog, outerTrigger);
      focusGuard.trap(innerDialog, innerTrigger);

      expect(document.body.querySelectorAll(".focusguard").length).toBe(2);

      focusGuard.disable();

      expect(document.body.querySelectorAll(".focusguard").length).toBe(2);
      expect(document.activeElement).toBe(innerTrigger);
    });

    it("removes guards when outer dialog is disabled last", () => {
      const outerDialog = document.createElement("div");
      const outerTrigger = document.createElement("button");
      const innerDialog = document.createElement("div");
      const innerTrigger = document.createElement("button");

      document.body.appendChild(outerDialog);
      document.body.appendChild(outerTrigger);
      document.body.appendChild(innerDialog);
      document.body.appendChild(innerTrigger);

      focusGuard.trap(outerDialog, outerTrigger);
      focusGuard.trap(innerDialog, innerTrigger);

      focusGuard.disable();
      focusGuard.disable();

      expect(document.body.querySelectorAll(".focusguard").length).toBe(0);
      expect(document.activeElement).toBe(outerTrigger);
    });

    it("cycles focus to the current top dialog when a guard receives focus", () => {
      jest.spyOn(focusGuard, "isVisible").mockReturnValue(true);

      const outerDialog = document.createElement("div");
      const outerInput = document.createElement("input");
      outerDialog.appendChild(outerInput);

      const innerDialog = document.createElement("div");
      const innerInput = document.createElement("input");
      innerDialog.appendChild(innerInput);

      document.body.appendChild(outerDialog);
      document.body.appendChild(innerDialog);

      focusGuard.trap(outerDialog, null);
      focusGuard.trap(innerDialog, null);

      const endGuard = document.body.querySelector('.focusguard[data-position="end"]');
      endGuard.focus();

      expect(document.activeElement).toBe(innerInput);
    });

    it("cycles focus backward to the current top dialog when the start guard receives focus", () => {
      jest.spyOn(focusGuard, "isVisible").mockReturnValue(true);

      const outerDialog = document.createElement("div");
      const outerInput = document.createElement("input");
      outerDialog.appendChild(outerInput);

      const innerDialog = document.createElement("div");
      const innerInput = document.createElement("input");
      const innerButton = document.createElement("button");
      innerDialog.appendChild(innerInput);
      innerDialog.appendChild(innerButton);

      document.body.appendChild(outerDialog);
      document.body.appendChild(innerDialog);

      focusGuard.trap(outerDialog, null);
      focusGuard.trap(innerDialog, null);

      const startGuard = document.body.querySelector('.focusguard[data-position="start"]');
      startGuard.focus();

      expect(document.activeElement).toBe(innerButton);
    });
  });
});
