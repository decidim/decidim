import "src/decidim/comments/comments_mobile_modal";

describe("Comments mobile modal", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-decidim-comments id="first">
        <button class="add-comment-mobile">Add comment</button>
        <div class="add-comment hidden">
          <button class="close-add-comment-fullscreen">Close</button>
        </div>
      </div>
      <div data-decidim-comments id="second">
        <button class="add-comment-mobile">Add comment</button>
        <div class="add-comment hidden">
          <button class="close-add-comment-fullscreen">Close</button>
        </div>
      </div>
    `;
  });

  it("opens only the comment card belonging to the clicked section", () => {
    const firstSection = document.querySelector("#first");
    const secondSection = document.querySelector("#second");

    firstSection.querySelector(".add-comment-mobile").click();

    expect(firstSection.querySelector(".add-comment").classList.contains("hidden")).toBe(false);
    expect(firstSection.querySelector(".add-comment").classList.contains("fullscreen")).toBe(true);
    expect(secondSection.querySelector(".add-comment").classList.contains("hidden")).toBe(true);
  });

  it("closes the comment card from its close button", () => {
    const section = document.querySelector("#first");
    const card = section.querySelector(".add-comment");

    section.querySelector(".add-comment-mobile").click();
    section.querySelector(".close-add-comment-fullscreen").click();

    expect(card.classList.contains("hidden")).toBe(true);
    expect(card.classList.contains("fullscreen")).toBe(false);
  });
});
