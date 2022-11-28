import $ from "jquery"; // eslint-disable-line id-length

import updateExternalDomainLinks from "./external_domain_warning";

describe("updateExternalDomainLinks", () => {
  const content = `
    <div id="links">
      <a href="https://github.com/" target="_blank">This is an external link</a>
      <a href="https://example.com/" target="_blank">This is an external link from a whitelisted domain</a>
      <div class="editor-container">
        <a href="https://example.org/" target="_blank">This is an external link within an editor</a>
      </div>
    </div>
  `;
  const config = {
    "external_domain_whitelist": [ "example.com" ]
  };
  window.Decidim = {
    config: {
      get: (key) => config[key]
    }
  }

  beforeEach(() => {
    $("body").html(content);
    updateExternalDomainLinks($("body"));
  });

  it("updates the link to the external link URL", () => {
    const $link = $("#links a")[0];

    expect($link.outerHTML).toEqual(
      `<a href="/link?external_url=https%3A%2F%2Fgithub.com%2F" target="_blank" data-remote="true">This is an external link</a>`
    );
  });

  it("doesn't update the link to the external link URL when its whitelisted", () => {
    const $link = $("#links a")[1];

    expect($link.outerHTML).toEqual(
      `<a href="https://example.com/" target="_blank">This is an external link from a whitelisted domain</a>`
    );
  });

  it("doesn't update the link to the external link URL when the parent class is excluded", () => {
    const $link = $("#links a")[2];

    expect($link.outerHTML).toEqual(
      `<a href="https://example.org/" target="_blank">This is an external link within an editor</a>`
    );
  });

});
