/* global spyOn */
/* eslint-disable id-length */
window.$ = require("jquery");

require("./delayed.js.es6");
require("./history.js.es6");
require("./data_picker.js.es6");
require("./check_boxes_tree.js.es6");
require("./form_filter.component.js.es6");

const { Decidim: { FormFilterComponent } } = window;

describe("FormFilterComponent", () => {
  const selector = "form#new_filter";
  let subject = null;
  let scopesPickerState = {filter_somerandomid_scope_id: [{ url: "picker_url_3", value: 3, text: "Scope 3"}, { url: "picker_url_4", value: 4, text: "Scope 4"}]} // eslint-disable-line camelcase

  beforeEach(() => {
    let form = `
      <form id="new_filter" action="/filters" method="get">
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

    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
    window.theCheckBoxesTree = new window.Decidim.CheckBoxesTree();
    subject = new FormFilterComponent($(document).find("form"));
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
      spyOn(subject.$form, "on");
      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    it("mounts the component", () => {
      expect(subject.mounted).toBeTruthy();
    });

    it("binds the form change event", () => {
      expect(subject.$form.on).toHaveBeenCalledWith("change", "input:not([data-disable-dynamic-change]), select:not([data-disable-dynamic-change])", subject._onFormChange);
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

    it("unbinds the form change event", () => {
      expect(subject.$form.off).toHaveBeenCalledWith("change", "input, select", subject._onFormChange);
    });
  });

  afterEach(() => {
    $(selector).remove();
  })
});
