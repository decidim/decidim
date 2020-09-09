((exports) => {
  const console = exports.console;

  if (!console) {
    return;
  }

  $(() => {
    const config = exports.Decidim.config;
    const messages = config.get("messages").selfxssWarning;

    console.log(`%c${messages.title}`, "color:#f00;font-weight:bold;font-size:50px;");
    console.log(`%c${messages.description}`, "font-size:24px;");
  });
})(window)
