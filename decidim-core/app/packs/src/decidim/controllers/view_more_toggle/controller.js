import { Controller } from "@hotwired/stimulus"

/**
 * Stimulus controller for the "view more" toggle of a content block's
 * participatory space main data description.
 *
 * When the description is long it is truncated into a panel that carries the
 * `inert` attribute, and a button reveals or hides it by toggling that
 * attribute. The button can be activated either by clicking it or, for keyboard
 * users, by pressing Enter or Space while it is focused. Both interactions are
 * routed through `toggle`: a click always toggles, while a keydown only toggles
 * for Enter (keyCode 13) or Space (keyCode 32), matching the original inline
 * behavior.
 *
 * The controller is mounted on the button itself (not on the accordion
 * container, whose exact `[data-controller="accordion"]` style selector must be
 * preserved). It resolves its own panel from the button's `data-controls`
 * attribute, which holds the unique panel id, so that when several content
 * blocks with a "view more" panel coexist on the same page each button toggles
 * its own panel.
 */
export default class ViewMoreToggleController extends Controller {

  /**
   * Toggles the `inert` attribute on this button's panel.
   *
   * Reacts to both click and keydown events: clicks always toggle, while
   * keydown events only toggle for Enter (keyCode 13) or Space (keyCode 32).
   * @param {(MouseEvent|KeyboardEvent)} event - The click or keydown event.
   * @returns {void}
   */
  toggle(event) {
    if (event.type === "keydown" && event.keyCode !== 13 && event.keyCode !== 32) {
      return;
    }

    const panel = document.getElementById(this.element.getAttribute("data-controls"));
    if (panel) {
      panel.toggleAttribute("inert");
    }
  }
}
