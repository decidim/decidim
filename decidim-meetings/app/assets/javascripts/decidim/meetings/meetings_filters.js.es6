// = require ./meetings_form_filter.component
// = require_self

((exports) => {
  const { DecidimMeetings: { MeetingsFormFilterComponent } } = exports;
  const meetingsFormFilter = new MeetingsFormFilterComponent('form#new_filter');

  const onDocumentReady = () => {
    meetingsFormFilter.mountComponent();
  };

  const onTurboLinksBeforeVisit = () => {
    meetingsFormFilter.unmountComponent();
    $(document).off('turbolinks:before-visit', onTurboLinksBeforeVisit);
  };

  $(document).ready(onDocumentReady);
  $(document).on('turbolinks:before-visit', onTurboLinksBeforeVisit);
})(window);
