import $ from "jquery"; // eslint-disable-line id-length

import ExternalLink from "./external_link";

describe("ExternalLink", () => {
  const content = `
    <div id="links">
      <a href="https://decidim.org/" target="_blank">This is an external link</a>
      <a href="https://decidim.org/" target="_blank" data-external-link="false">This is an normal link</a>
    </div>
  `;

  const config = {
    "icons_path": "/path/to/icons.svg"
  };
  window.Decidim = {
    config: {
      get: (key) => config[key]
    }
  }
  const expectedIcon = "<svg width=\"0.75em\" height=\"0.75em\" role=\"img\" aria-hidden=\"true\" class=\"fill-current\"><title>external-link-line</title><use href=\"/path/to/icons.svg#ri-external-link-line\"></use></svg><span class=\"sr-only\">(External link)</span>";

  beforeEach(() => {
    document.body.innerHTML = content
    document.querySelectorAll("a[target=\"_blank\"]:not([data-external-link=\"false\"])").forEach((elem) => new ExternalLink(elem))
  });

  it("adds the external link indicator to the external link", () => {
    const $link = $("#links a")[0];

    expect($link.outerHTML).toEqual(
      `<a href="https://decidim.org/" target="_blank">This is an external link<span data-external-link="true" class="inline-block mx-0.5">${expectedIcon}</span></a>`
    );
  });

  it("does not add the external link when is disabled", () => {
    const $link = $("#links a")[1];

    expect($link.outerHTML).toEqual(
      "<a href=\"https://decidim.org/\" target=\"_blank\" data-external-link=\"false\">This is an normal link</a>"
    );
  });
});
