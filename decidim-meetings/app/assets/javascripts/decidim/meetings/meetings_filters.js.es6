// = require ./meetings_form_filter.component
// = require_self

// Initializes the meetings filter. We're unmounting the component before
// changing the page so that we stop listening to events and we don't bind
// multiple times when re-visiting the page.
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
