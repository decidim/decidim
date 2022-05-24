import { reportingErrors } from "src/decidim/reporting_errors";

$(reportingErrors(async () => {
  const $onboarding = $("#onboarding-modal");
  $onboarding.foundation("open");
}));
