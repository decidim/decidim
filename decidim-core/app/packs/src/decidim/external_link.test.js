import $ from "jquery"; // eslint-disable-line id-length

import ExternalLink from "./external_link";

describe("ExternalLink", () => {
  const content = `
    <div id="links">
      <a href="https://decidim.org/" target="_blank">This is an external link</a>
      <a href="https://decidim.org/" target="_blank"><img src="/path/to/image.png" alt=""></a>
      <a href="https://decidim.org/" target="_blank" data-external-link-spacer="%%%">Custom spacer link</a>
      <a href="https://decidim.org/" target="_blank" data-external-link-target=".external-wrapper"><span class="external-wrapper"></span>This is the link</a>
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
  const expectedIcon = '<svg class="icon icon--external-link" role="img" aria-hidden="true"><title>external-link</title><use href="/path/to/icons.svg#icon-external-link"></use></svg>';

  beforeEach(() => {
    $("body").html(content);
    $('a[target="_blank"]').each((_i, elem) => {
      const $link = $(elem);
      $link.data("external-link", new ExternalLink($link));
    });
  });

  it("adds the external link indicator to the normal external link", () => {
    const $link = $("#links a")[0];

    expect($link.outerHTML).toEqual(
      `<a href="https://decidim.org/" target="_blank" class="external-link-container">This is an external link&nbsp;<span class="external-link-indicator">${expectedIcon}<span class="show-for-sr">(External link)</span></span></a>`
    );
  });

  it("adds the external link indicator without a spacer to the image link", () => {
    const $link = $("#links a")[1];

    expect($link.outerHTML).toEqual(
      `<a href="https://decidim.org/" target="_blank" class="external-link-container"><img src="/path/to/image.png" alt=""><span class="external-link-indicator">${expectedIcon}<span class="show-for-sr">(External link)</span></span></a>`
    );
  });

  it("adds the external link indicator with a custom spacer to the link with the custom spacer configuration", () => {
    const $link = $("#links a")[2];

    expect($link.outerHTML).toEqual(
      `<a href="https://decidim.org/" target="_blank" data-external-link-spacer="%%%" class="external-link-container">Custom spacer link%%%<span class="external-link-indicator">${expectedIcon}<span class="show-for-sr">(External link)</span></span></a>`
    );
  });

  it("adds the external link indicator with a custom container to the link with the custom container configuration", () => {
    const $link = $("#links a")[3];

    expect($link.outerHTML).toEqual(
      `<a href="https://decidim.org/" target="_blank" data-external-link-target=".external-wrapper"><span class="external-wrapper external-link-container"><span class="external-link-indicator">${expectedIcon}<span class="show-for-sr">(External link)</span></span></span>This is the link</a>`
    );
  });
});
