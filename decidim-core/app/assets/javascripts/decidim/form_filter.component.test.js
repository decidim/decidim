/* global spyOn */
/* eslint-disable id-length */
window.$ = require("jquery");

require("./history.js.es6");
require("./data_picker.js.es6");
require("./form_filter.component.js.es6");

const { Decidim: { FormFilterComponent } } = window;

describe("FormFilterComponent", () => {
  const selector = "form#new_filter";
  let subject = null;
  let scopesPickerState = {filter_scope_id: [{ url: "picker_url_3", value: 3, text: "Scope 3"}, { url: "picker_url_4", value: 4, text: "Scope 4"}]} // eslint-disable-line camelcase

  beforeEach(() => {
    let form = `
      <form id="new_filter" action="/filters" method="get">
        <fieldset>
          <div id="filter_scope_id" class="data-picker picker-multiple" data-picker-name="filter[scope_id]">
            <div class="picker-values">
              <div>
                <a href="picker_url_1" data-picker-value="1">Scope 1</a>
              </div>
              <div>
                <a href="picker_url_2" data-picker-value="1">Scope 2</a>
              </div>
            </div>
            <div class="picker-prompt">
              <a href="picker_url">Seleccione un ámbito</a>
            </div>
          </div>
        </fieldset>

        <fieldset>
          <select id="filter_category_id" name="filter[category_id]">
            <option value="1">Category 1</option>
            <option value="2">Category 2</option>
          </select>
        </fieldset>
      </form>
    `;
    $("body").append(form);

    window.theDataPicker = new window.Decidim.DataPicker($(".data-picker"));
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
      expect(subject.$form.on).toHaveBeenCalledWith("change", "input, select", subject._onFormChange);
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
        spyOn(subject, "_getLocation").and.returnValue("/filters?filter[scope_id][]=3&filter[scope_id][]=4&filter[category_id]=2");
        window.onpopstate({ isTrusted: true, state: scopesPickerState});

        expect($(selector).find("select#filter_category_id").val()).toEqual("2");
        expect($(`${selector} #filter_scope_id .picker-values div input`).map(function(_index, input) {
          return $(input).val();
        }).get()).toEqual(["3", "4"]);
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
