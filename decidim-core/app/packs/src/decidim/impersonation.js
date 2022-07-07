import dayjs from "dayjs"

$(() => {
  const $impersonationWarning = $(".impersonation-warning");
  if ($impersonationWarning.length) {
    const endsAt = dayjs($impersonationWarning.data("session-ends-at"));
    const exitInterval = setInterval(() => {
      const diff = (endsAt - dayjs()) / 60000;
      const diffInMinutes = Math.round(diff);
      $impersonationWarning.find(".minutes").html(diffInMinutes);

      if (diff <= 0) {
        window.location.reload();
      }
    }, 1000);

    // Prevent reload when page is already unloading, otherwise it may cause infinite reloads.
    window.addEventListener("beforeunload", () => {
      clearInterval(exitInterval);
      return;
    });
  }
});
