((exports) => {
  exports.$(() => {
    const $impersonationWarning = $('.impersonation-warning');
    const endsAt = exports.moment($impersonationWarning.data('session-ends-at'));

    setInterval(() => {
      const diff = (endsAt - exports.moment()) / 60000;
      const diffInMinutes = Math.round(diff);
      $impersonationWarning.find('.minutes').html(diffInMinutes);

      if (diff <= 0) {
        window.location.reload();
      }
    }, 1000);
  });
})(window);
