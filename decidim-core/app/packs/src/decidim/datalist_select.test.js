/* global jest */

import { datalistSelect } from "src/decidim/datalist_select";

describe("datalistSelect", () => {
  let target = null;

  beforeEach(() => {
    document.body.innerHTML = `
      <div>
        <input type="hidden">
        <input type="text">
        <datalist>
          <option data-value="42">Test: Use of special characters ?!-&amp;</option>
        </datalist>
      </div>
    `;
    target = document.querySelector("div");
  });

  it("selects an option whose label contains an ampersand", () => {
    const callback = jest.fn();
    const textInput = target.querySelector("input[type='text']");

    datalistSelect(target, callback);
    textInput.value = "Test: Use of special characters ?!-&";
    textInput.dispatchEvent(new Event("input"));

    expect(target.querySelector("input[type='hidden']").value).toBe("42");
    expect(callback).toHaveBeenCalledWith("42");
  });
});
