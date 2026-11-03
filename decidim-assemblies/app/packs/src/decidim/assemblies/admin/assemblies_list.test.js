/* global jest */

window.Decidim = window.Decidim || {};

describe("AdminAssembliesListComponent", () => {
  let assemblyRow = null;
  let downArrow = null;
  let upArrow = null;

  const click = (element) => {
    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    element.dispatchEvent(event);
    return event;
  };

  beforeEach(() => {
    jest.resetModules();
    document.body.innerHTML = `
      <table>
        <tbody>
          <tr data-assembly-id="1" data-level="0">
            <td>
              <a href="/assemblies?q%5Bparent_id_eq%5D=1" data-remote="true" data-arrow-down>Down</a>
              <a href="#" class="hidden" data-arrow-up>Up</a>
            </td>
          </tr>
        </tbody>
      </table>
    `;
    // eslint-disable-next-line global-require
    require("./assemblies_list");

    assemblyRow = document.querySelector('[data-assembly-id="1"]');
    downArrow = assemblyRow.querySelector("[data-arrow-down]");
    upArrow = assemblyRow.querySelector("[data-arrow-up]");
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  it("adds the spinner and loading state when expanding", () => {
    click(downArrow);

    expect(assemblyRow.classList.contains("spinner-container")).toBe(true);
    expect(assemblyRow.dataset.loading).toBe("true");
    expect(assemblyRow.getAttribute("aria-busy")).toBe("true");
    expect(downArrow.classList.contains("hidden")).toBe(true);
    expect(upArrow.classList.contains("hidden")).toBe(false);
  });

  it("ignores repeated and collapse clicks while loading", () => {
    click(downArrow);

    const repeatClick = click(downArrow);
    const collapseClick = click(upArrow);

    expect(repeatClick.defaultPrevented).toBe(true);
    expect(collapseClick.defaultPrevented).toBe(true);
    expect(assemblyRow.classList.contains("spinner-container")).toBe(true);
    expect(assemblyRow.dataset.loading).toBe("true");
    expect(downArrow.classList.contains("hidden")).toBe(true);
    expect(upArrow.classList.contains("hidden")).toBe(false);
  });

  it("clears the spinner and loading state on ajax:error", () => {
    click(downArrow);

    downArrow.dispatchEvent(new CustomEvent("ajax:error", { bubbles: true }));

    expect(assemblyRow.classList.contains("spinner-container")).toBe(false);
    expect(assemblyRow.dataset.loading).toBe("false");
    expect(assemblyRow.hasAttribute("aria-busy")).toBe(false);
  });

  it("allows collapsing after an ajax error", () => {
    click(downArrow);
    downArrow.dispatchEvent(new CustomEvent("ajax:error", { bubbles: true }));

    click(upArrow);

    expect(upArrow.classList.contains("hidden")).toBe(true);
    expect(downArrow.classList.contains("hidden")).toBe(false);
  });
});
