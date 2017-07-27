((exports) => {
  exports.$(() => {
    const $impersonationWarning = $('.impersonation-warning');
    const endsAt = exports.moment($impersonationWarning.data('session-ends-at'));

    setInterval(() => {
      const diffInMinutes = Math.round((endsAt - exports.moment()) / 60000);
      $impersonationWarning.find('.minutes').html(diffInMinutes);

      if (diffInMinutes <= 0) {
        window.location.reload();
      }
    }, 1000);
  });
})(window);
