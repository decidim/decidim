/* global spyOn, jest */
/* eslint-disable id-length */
window.$ = $;

import CheckBoxesTree from "./check_boxes_tree"
import DataPicker from "./data_picker"

const FormFilterComponent = require("./form_filter.component_for_testing.js");

const expectedPushState = (state, filters) => {
  const queryString = Object.keys(filters).map((key) => {
    const name = `filter[${key}]`;
    const val = filters[key];
    if (Array.isArray(val)) {
      return val.map((v) => `${encodeURIComponent(`${name}[]`)}=${encodeURIComponent(v)}`).join("&");
    }

    return `${encodeURIComponent(name)}=${encodeURIComponent(val)}`;
  }).join("&");

  return [state, null, `/filters?${queryString}`];
}

describe("FormFilterComponent", () => {
  const selector = "form#new_filter";
  let subject = null;
  let scopesPickerState = {filter_somerandomid_scope_id: [{ url: "picker_url_3", value: 3, text: "Scope 3"}, { url: "picker_url_4", value: 4, text: "Scope 4"}]} // eslint-disable-line camelcase

  beforeEach(() => {
    let form = `
      <form id="new_filter" action="/filters" method="get">
        <fieldset>
          <input id="filter_search_text_cont" placeholder="Search" data-disable-dynamic-change="true" type="search" name="filter[search_text_cont]">
        </fieldset>

        <fieldset>
          <div id="filter_somerandomid_scope_id" class="data-picker picker-multiple" data-picker-name="filter[scope_id]">
            <div class="picker-values">
              <div>
                <a href="picker_url_1" data-picker-value="3">Scope 1</a>
              </div>
              <div>
                <a href="picker_url_2" data-picker-value="4">Scope 2</a>
              </div>
            </div>
            <div class="picker-prompt">
              <a href="picker_url">Seleccione un ámbito</a>
            </div>
          </div>
        </fieldset>

        <fieldset>
          <select id="filter_somerandomid_category_id" name="filter[category_id]">
            <option value="1">Category 1</option>
            <option value="2">Category 2</option>
          </select>
        </fieldset>

        <fieldset>
          <input type="hidden" name="filter[state][]" id="filter_state_" value="">
          <label data-global-checkbox="" for="filter_state_all">
            <input data-checkboxes-tree="state-options" value="" type="checkbox" name="filter[state][]" id="filter_state_all" class="ignore-filter">
            All
          </label>
          <div id="state-options" class="filters__subfilters ">
            <label data-children-checkbox="" for="filter_state_accepted">
              <input value="accepted" type="checkbox" name="filter[state][]" id="filter_state_accepted" class="ignore-filter">
              Accepted
            </label>
            <label data-children-checkbox="" for="filter_state_evaluating">
              <input value="evaluating" type="checkbox" name="filter[state][]" id="filter_state_evaluating" class="ignore-filter">
              Evaluating
            </label>
            <label data-children-checkbox="" for="filter_state_not_answered">
              <input value="not_answered" type="checkbox" name="filter[state][]" id="filter_state_not_answered" class="ignore-filter">
              Not answered
            </label>
            <label data-children-checkbox="" for="filter_state_rejected">
              <input value="rejected" type="checkbox" name="filter[state][]" id="filter_state_rejected" class="ignore-filter">
              Rejected
            </label>
          </div>
        </fieldset>
      </form>
    `;
    $("body").append(form);

    const $form = $(document).find("form");

    window.Decidim = window.Decidim || {};

    window.theDataPicker = new DataPicker($(".data-picker"));
    window.theCheckBoxesTree = new CheckBoxesTree();
    window.Rails = {
      fire: (htmlElement, event) => {
        // Hack to call trigger on the correct instance of the form, as fetching
        // with the selector does not work.
        if (htmlElement === $form[0]) {
          $form.trigger(event);
        }
      }
    };

    subject = new FormFilterComponent($form);

    jest.useFakeTimers();
  });

  it("exists", () => {
    expect(FormFilterComponent).toBeDefined();
  });

  it("initializes unmounted", () => {
    expect(subject.mounted).toBeFalsy();
  });

  it("initializes the formSelector with the given selector", () => {
    expect(subject.$form).toEqual($(selector));
  });

  describe("when mounted", () => {
    beforeEach(() => {
      // Jest doesn't implement listening on the form submit event so we need
      // to hack it.
      const originalOn = subject.$form.on.bind(subject.$form);
      jest.spyOn(subject.$form, "on").mockImplementation((...args) => {
        if (args[0] === "submit") {
          subject.$form.submitHandler = args[1];
        } else if (args[0] === "change" && typeof args[1] === "string") {
          subject.$form.changeHandler = args[2];
        } else {
          originalOn(...args);
        }
      });

      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeTruthy();
    });

    it("binds the form change and submit events", () => {
      expect(subject.$form.on).toHaveBeenCalledWith("change", "input:not([data-disable-dynamic-change]), select:not([data-disable-dynamic-change])", subject._onFormChange);
      expect(subject.$form.on).toHaveBeenCalledWith("submit", subject._onFormSubmit);
    });

    describe("form changes", () => {
      beforeEach(() => {
        spyOn(window.history, "pushState");

        // This is a hack to be able to trigger the events even somewhat close
        // to an actual situation. In real browser environment the change events
        // would be triggered by the input/select elements but to simplify the
        // test implementation, we trigger them directly on the form.
        const originalTrigger = subject.$form.trigger.bind(subject.$form);
        jest.spyOn(subject.$form, "trigger").mockImplementation((...args) => {
          if (args[0] === "submit") {
            subject.$form.submitHandler();
          } else if (args[0] === "change") {
            subject.$form.changeHandler();
          } else {
            originalTrigger(...args);
          }

          jest.runAllTimers();
        });
      });

      it("does not save the state in case there were no changes to previous state", () => {
        subject.$form.trigger("change");

        expect(window.history.pushState).not.toHaveBeenCalled();
      });

      it("saves the state after dynamic form changes", () => {
        $("#filter_somerandomid_category_id").val(2);

        subject.$form.trigger("change");

        const state = {
          "filter_somerandomid_scope_id": [
            {
              "text": "Scope 1",
              "url": "picker_url_1",
              "value": "3"
            },
            {
              "text": "Scope 2",
              "url": "picker_url_2",
              "value": "4"
            }
          ]
        };
        const filters = {
          "search_text_cont": "",
          "scope_id": [3, 4],
          "category_id": 2,
          "state": [""]
        };
        expect(window.history.pushState).toHaveBeenCalledWith(...expectedPushState(state, filters));
      });

      it("saves the state after form submission through input element", () => {
        const textInput = document.getElementById("filter_search_text_cont");
        textInput.value = "search";

        subject.$form.trigger("submit");

        const state = {
          "filter_somerandomid_scope_id": [
            {
              "text": "Scope 1",
              "url": "picker_url_1",
              "value": "3"
            },
            {
              "text": "Scope 2",
              "url": "picker_url_2",
              "value": "4"
            }
          ]
        }
        const filters = {
          "search_text_cont": "search",
          "scope_id": [3, 4],
          "category_id": 1,
          "state": [""]
        }

        expect(window.history.pushState).toHaveBeenCalledWith(...expectedPushState(state, filters));
      });
    });

    describe("onpopstate event", () => {
      beforeEach(() => {
        spyOn(subject.$form, "submit");
      });

      it("clears the form data", () => {
        spyOn(subject, "_clearForm");

        window.onpopstate({ isTrusted: true, state: scopesPickerState});

        expect(subject._clearForm).toHaveBeenCalled();
      });

      it("sets the correct form fields based on the current location", () => {
        const path = "/filters?filter[scope_id][]=3&filter[scope_id][]=4&filter[category_id]=2&filter[state][]=&filter[state][]=accepted&filter[state][]=evaluating";
        spyOn(subject, "_getLocation").and.returnValue(path);
        window.onpopstate({ isTrusted: true, state: scopesPickerState});

        expect($(selector).find("select#filter_somerandomid_category_id").val()).toEqual("2");
        expect($(`${selector} #filter_somerandomid_scope_id .picker-values div input`).map(function(_index, input) {
          return $(input).val();
        }).get()).toEqual(["3", "4"]);

        let checked = Array.from($(`${selector} input[name="filter[state][]"]:checked`));
        expect(checked.map((input) => input.value)).toEqual(["", "accepted", "evaluating"]);
        expect(checked.filter((input) => input.indeterminate).map((input) => input.value)).toEqual([""]);
      });
    });
  });

  describe("when unmounted", () => {
    beforeEach(() => {
      spyOn(subject.$form, "off");
      subject.mountComponent();
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeFalsy();
    });

    it("unbinds the form change and submit events", () => {
      expect(subject.$form.off).toHaveBeenCalledWith("change", "input, select", subject._onFormChange);
      expect(subject.$form.off).toHaveBeenCalledWith("submit", subject._onFormSubmit);
    });
  });

  afterEach(() => {
    $(selector).remove();
  })
});
