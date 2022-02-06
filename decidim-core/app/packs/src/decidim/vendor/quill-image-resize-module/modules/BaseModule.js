export class BaseModule {
    constructor(resizer) {
        this.overlay = resizer.overlay;
        this.img = resizer.img;
        this.options = resizer.options;
        this.requestUpdate = resizer.onUpdate;
    }
    /*
        requestUpdate (passed in by the library during construction, above) can be used to let the library know that
        you've changed something about the image that would require re-calculating the overlay (and all of its child
        elements)
        For example, if you add a margin to the element, you'll want to call this or else all the controls will be
        misaligned on-screen.
     */

    /*
        onCreate will be called when the element is clicked on
        If the module has any user controls, it should create any containers that it'll need here.
        The overlay has absolute positioning, and will be automatically repositioned and resized as needed, so you can
        use your own absolute positioning and the 'top', 'right', etc. styles to be positioned relative to the element
        on-screen.
     */
    onCreate() {};

    /*
        onDestroy will be called when the element is de-selected, or when this module otherwise needs to tidy up.
        If you created any DOM elements in onCreate, please remove them from the DOM and destroy them here.
     */
    onDestroy() {};

    /*
        onUpdate will be called any time that the element is changed (e.g. resized, aligned, etc.)
        This frequently happens during resize dragging, so keep computations light while here to ensure a smooth
        user experience.
     */
    onUpdate() {};
}
