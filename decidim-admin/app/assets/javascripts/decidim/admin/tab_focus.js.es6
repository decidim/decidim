//= require_self

/**
 * When switching tabs in i18n fields, autofocus on the input to save clicks #212
 */
$(document).on('turbolinks:load', () => {

    //Event launched by foundation
    $('[data-tabs]').on('change.zf.tabs', function() {
        let $el_container = $(this).next('.tabs-content .tabs-panel.is-active');
        //Detect quilljs editor inside the tabs-panel
        let $el_content = $el_container.find('.editor .ql-editor');
        if($el_content.length > 0) {
            $el_content.focus();
        //Detect if inside the tabs-panel have an input
        } else {
            $el_content = $el_container.find('input:first');
            if($el_content.length > 0) {
                $el_content.focus();
            }
        }
    });
});
