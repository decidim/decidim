/* global spyOn */
/* eslint-disable id-length */
window.$ = require('jquery');
require('select2');

require('./history.js.es6');
require('./select2.field.js.es6');
require('./form_filter.component.js.es6');

const { Decidim: { FormFilterComponent } } = window;

describe('FormFilterComponent', () => {
  const selector = 'form#new_filter';
  let subject = null;

  beforeEach(() => {
    let form = `
      <form id="new_filter" action="/filters" method="get">
        <fieldset>
          <select id="filter_scope_id" name="filter[scope_id]" class="select2" multiple>
            <option value="1">Scope 1</option>
            <option value="2">Scope 2</option>
            <option value="3">Scope 3</option>
          </select>
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
      expect(subject.$form.on).toHaveBeenCalledWith('change', 'input:not(.select2-search__field), select', subject._onFormChange);
    });

    describe('onpopstate event', () => {
      beforeEach(() => {
        spyOn(subject.$form, 'submit');
      });

      it('clears the form data', () => {
        spyOn(subject, '_clearForm');

        window.onpopstate({ isTrusted: true });

        expect(subject._clearForm).toHaveBeenCalled();
      });

      it('sets the correct form fields based on the current location', () => {
        spyOn(subject, '_getLocation').and.returnValue('/filters?filter[scope_id][]=1&scope_id[]=2&filter[category_id]=2');
        window.onpopstate({ isTrusted: true });

        expect($(selector).find('select#filter_category_id').val()).toEqual('2');
        expect($(selector).find('select#filter_scope_id').val()).toEqual(['1']);
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
      expect(subject.$form.off).toHaveBeenCalledWith('change', 'input:not(.select2-search__field), select', subject._onFormChange);
    });
  });

  afterEach(() => {
    $(selector).remove();
  })
});
