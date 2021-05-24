import MeetingsPollComponent from "src/decidim/meetings/poll.component"

$(() => {
  // Mount polls component for plain users
  const $container = $("[data-decidim-meetings-poll]");
  const $counter = $("#visible-questions-count");
  const poll = new MeetingsPollComponent($container, $container.data("decidim-meetings-poll"), $counter);

  $(".meeting-polls__action-list").on("click", (event) => {
    event.preventDefault();

    if(!poll.isMounted()){
      $(event.target).addClass("is-open");
      $container.addClass("is-open");
      poll.mountComponent();
    } else {
      $(event.target).removeClass("is-open");
      $container.removeClass("is-open");
      poll.unmountComponent();
    }
  });

  // Mount polls component for admins
  const $adminContainer = $("[data-decidim-admin-meetings-poll]");
  const adminPoll = new MeetingsPollComponent($adminContainer, $adminContainer.data("decidim-admin-meetings-poll"));

  $(".meeting-polls__action-administrate").on("click", (event) => {
    event.preventDefault();

    if(!adminPoll.isMounted()){
      $(event.target).addClass("is-open");
      $adminContainer.addClass("is-open");
      adminPoll.mountComponent();
    } else {
      $(event.target).removeClass("is-open");
      $adminContainer.removeClass("is-open");
      adminPoll.unmountComponent();
    }
  });
});
