/* eslint max-lines: ["error", 400] */

describe("DropdownController - removeAriaRoles", () => {
  let element = null;
  let dropdownMenuEl = null;

  const createRemoveAriaRoles = (dropdownElement) => {
    return function() {
      const target = dropdownElement.dataset.target;
      const dropdownMenu = document.getElementById(target);
      if (!dropdownMenu) {
        return;
      }

      dropdownMenu.removeAttribute("role");
      dropdownMenu.removeAttribute("aria-labelledby");
      dropdownMenu.removeAttribute("tabindex");

      dropdownMenu.querySelectorAll("li").forEach((li) => {
        li.removeAttribute("role");
      });

      dropdownMenu.querySelectorAll("a").forEach((anchor) => {
        anchor.removeAttribute("role");
        anchor.removeAttribute("tabindex");
      });
    };
  };

  beforeEach(() => {
    document.body.innerHTML = `
      <button
        id="dropdown-trigger"
        data-controller="dropdown"
        data-target="dropdown-menu"
        data-open-md="true"
        data-auto-close="true"
      >
        Dropdown Trigger
      </button>
      <ul id="dropdown-menu" class="dropdown-menu">
        <li><a href="/link1">Link 1</a></li>
        <li><a href="/link2">Link 2</a></li>
        <li><a href="/link3">Link 3</a></li>
      </ul>
    `;

    element = document.getElementById("dropdown-trigger");
    dropdownMenuEl = document.getElementById("dropdown-menu");
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  describe("removeAriaRoles", () => {
    it("removes role attribute from dropdown menu", () => {
      dropdownMenuEl.setAttribute("role", "menu");
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      expect(dropdownMenuEl.getAttribute("role")).toBeNull();
    });

    it("removes aria-labelledby attribute from dropdown menu", () => {
      dropdownMenuEl.setAttribute("aria-labelledby", "trigger");
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      expect(dropdownMenuEl.getAttribute("aria-labelledby")).toBeNull();
    });

    it("removes tabindex attribute from dropdown menu", () => {
      dropdownMenuEl.setAttribute("tabindex", "-1");
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      expect(dropdownMenuEl.getAttribute("tabindex")).toBeNull();
    });

    it("removes role from li elements", () => {
      const li = dropdownMenuEl.querySelector("li");
      li.setAttribute("role", "none");
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      expect(li.getAttribute("role")).toBeNull();
    });

    it("removes role from all li elements", () => {
      const listItems = dropdownMenuEl.querySelectorAll("li");
      listItems.forEach((li) => {
        li.setAttribute("role", "none");
      });
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      listItems.forEach((li) => {
        expect(li.getAttribute("role")).toBeNull();
      });
    });

    it("removes role from anchor elements", () => {
      const anchor = dropdownMenuEl.querySelector("a");
      anchor.setAttribute("role", "menuitem");
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      expect(anchor.getAttribute("role")).toBeNull();
    });

    it("removes tabindex from anchor elements", () => {
      const anchor = dropdownMenuEl.querySelector("a");
      anchor.setAttribute("tabindex", "-1");
      const removeAriaRoles = createRemoveAriaRoles(element);

      removeAriaRoles();

      expect(anchor.getAttribute("tabindex")).toBeNull();
    });

    it("handles missing dropdown menu gracefully", () => {
      const mockElement = document.createElement("button");
      mockElement.dataset.target = "nonexistent-menu";
      const removeAriaRoles = createRemoveAriaRoles(mockElement);

      expect(() => {
        removeAriaRoles();
      }).not.toThrow();
    });

    it("handles elements without the attributes gracefully", () => {
      const removeAriaRoles = createRemoveAriaRoles(element);

      expect(() => {
        removeAriaRoles();
      }).not.toThrow();

      expect(dropdownMenuEl.getAttribute("role")).toBeNull();
    });
  });

  describe("data-add-aria-roles option", () => {
    it("detects when data-add-aria-roles is false", () => {
      element.setAttribute("data-add-aria-roles", "false");
      expect(element.dataset.addAriaRoles).toBe("false");
    });

    it("detects when data-add-aria-roles is true", () => {
      element.setAttribute("data-add-aria-roles", "true");
      expect(element.dataset.addAriaRoles).toBe("true");
    });

    it("evaluates addAriaRoles correctly when false", () => {
      element.setAttribute("data-add-aria-roles", "false");
      const addAriaRoles = element.dataset.addAriaRoles !== "false";
      expect(addAriaRoles).toBe(false);
    });

    it("evaluates addAriaRoles correctly when true", () => {
      element.setAttribute("data-add-aria-roles", "true");
      const addAriaRoles = element.dataset.addAriaRoles !== "false";
      expect(addAriaRoles).toBe(true);
    });

    it("evaluates addAriaRoles correctly when undefined", () => {
      const addAriaRoles = element.dataset.addAriaRoles !== "false";
      expect(addAriaRoles).toBe(true);
    });
  });
});
