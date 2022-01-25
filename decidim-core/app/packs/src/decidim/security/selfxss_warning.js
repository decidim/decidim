/* eslint-disable no-console, no-process-env, no-undef */

$(() => {
  if (!console) {
    return;
  }

  if (process.env.NODE_ENV === "development") {
    return;
  }

  const allMessages = window.Decidim.config.get("messages");
  if (!allMessages) {
    return;
  }
  const messages = allMessages.selfxssWarning;

  console.log(`%c${messages.title}`, "color:#f00;font-weight:bold;font-size:50px;");
  console.log(`%c${messages.description}`, "font-size:24px;");
});
