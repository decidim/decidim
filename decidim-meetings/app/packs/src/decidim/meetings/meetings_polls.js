import MeetingsPollComponent from "src/decidim/meetings/poll.component"
const OPEN_CLASS = "is-open";

$(() => {
  // Mount polls component for users
  const $container = $("[data-decidim-meetings-poll]");
  const $counter = $("#visible-questions-count");
  const poll = new MeetingsPollComponent($container, $container.data("decidim-meetings-poll"), $counter);

  $(".meeting-polls__action-list").on("click", (event) => {
    event.preventDefault();

    if(!poll.isMounted()){
      $(event.target).addClass(OPEN_CLASS);
      $container.addClass(OPEN_CLASS);
      poll.mountComponent();
    } else {
      $(event.target).removeClass(OPEN_CLASS);
      $container.removeClass(OPEN_CLASS);
      poll.unmountComponent();
    }
  });

  // Mount polls component for admins
  const $adminContainer = $("[data-decidim-admin-meetings-poll]");
  const adminPoll = new MeetingsPollComponent($adminContainer, $adminContainer.data("decidim-admin-meetings-poll"));

  $(".meeting-polls__action-administrate").on("click", (event) => {
    event.preventDefault();

    if(!adminPoll.isMounted()){
      $(event.target).addClass(OPEN_CLASS);
      $adminContainer.addClass(OPEN_CLASS);
      adminPoll.mountComponent();
    } else {
      $(event.target).removeClass(OPEN_CLASS);
      $adminContainer.removeClass(OPEN_CLASS);
      adminPoll.unmountComponent();
    }
  });
});
