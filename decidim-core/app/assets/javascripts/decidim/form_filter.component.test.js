/* global spyOn */
/* eslint-disable id-length */
const $ = require('jquery');

require('./history.js.es6');
require('./form_filter.component.js.es6');

const { Decidim: { FormFilterComponent } } = window;

describe('FormFilterComponent', () => {
  const selector = 'form#new_filter';
  let subject = null;

  beforeEach(() => {
    let form = `
      <form id="new_filter" action="/filters" method="get">
        <fieldset>
          <input id="filter_scope_id_1" value="1" type="checkbox" name="filter[scope_id][]" />
          <input id="filter_scope_id_2" value="2" type="checkbox" name="filter[scope_id][]" />
          <input id="filter_scope_id_3" value="3" type="checkbox" name="filter[scope_id][]" />
        </fieldset>

        <fieldset>
          <select id="filter_category_id" name="filter[category_id]">
            <option value="1">Category 1</option>
            <option value="2">Category 2</option>
          </select>
        </fieldset>
      </form>
    `;
    $('body').append(form);
    subject = new FormFilterComponent($(document).find('form'));
  });

  it('exists', () => {
    expect(FormFilterComponent).toBeDefined();
  });

  it('initializes unmounted', () => {
    expect(subject.mounted).toBeFalsy();
  });

  it('initializes the formSelector with the given selector', () => {
    expect(subject.$form).toEqual($(selector));
  });

  describe('when mounted', () => {
    beforeEach(() => {
      spyOn(subject.$form, 'on');
      subject.mountComponent();
    });

    afterEach(() => {
      subject.unmountComponent();
    });

    it('mounts the component', () => {
      expect(subject.mounted).toBeTruthy();
    });

    it('binds the form change event', () => {
      expect(subject.$form.on).toHaveBeenCalledWith('change', 'input, select', subject._onFormChange);
    });

    describe('onpopstate event', () => {
      beforeEach(() => {
        spyOn(subject.$form, 'submit');
      });

      it('clears the form data', () => {
        spyOn(subject, '_clearForm');

        window.onpopstate();

        expect(subject._clearForm).toHaveBeenCalled();
      });

      it('sets the correct form fields based on the current location', () => {
        spyOn(subject, '_getLocation').and.returnValue('/filters?filter[scope_id][]=1&scope_id[]=2&filter[category_id]=2');
        window.onpopstate();

        expect($(selector).find('select').val()).toEqual('2');
        expect($(selector).find('input[name="filter[scope_id][]"][value="1"]')[0].checked).toBeTruthy();
        expect($(selector).find('input[name="filter[scope_id][]"][value="2"]')[0].checked).toBeFalsy();
        expect($(selector).find('input[name="filter[scope_id][]"][value="3"]')[0].checked).toBeFalsy();
      });
    });
  });

  describe('when unmounted', () => {
    beforeEach(() => {
      spyOn(subject.$form, 'off');
      subject.mountComponent();
      subject.unmountComponent();
    });

    it('mounts the component', () => {
      expect(subject.mounted).toBeFalsy();
    });

    it('unbinds the form change event', () => {
      expect(subject.$form.off).toHaveBeenCalledWith('change', 'input, select', subject._onFormChange);
    });
  });

  afterEach(() => {
    $(selector).remove();
  })
});
