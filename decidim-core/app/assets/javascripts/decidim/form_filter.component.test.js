/* eslint-disable no-unused-expressions */
require('jquery');
require('./form_filter.component.js.es6');

const { Decidim: { FormFilterComponent } } = window;

describe('FormFilterComponent', () => {
  const selector = 'form#new_filter';
  let subject = null;

  beforeEach(() => {
    let form = `
      <form id="new_filter" action="/filters" method="get">
        <input value="asc" type="radio" name="order_start_time" checked />
        <input value="desc" type="radio" name="order_start_time" />

        <input value="1" type="checkbox" name="scope_id[]" />
        <input value="2" type="checkbox" name="scope_id[]" />
        <input value="3" type="checkbox" name="scope_id[]" />

        <select id="filter_category_id" name="filter[category_id]">
          <option value="1">Category 1</option>
          <option value="2">Category 2</option>
        </select>
      </form>
    `;
    $('body').append(form);
    window.history = {
      pushState: sinon.stub()
    };
    subject = new FormFilterComponent(selector);
  });

  it('exists', () => {
    expect(FormFilterComponent).to.exist;
  });

  it('initializes unmounted', () => {
    expect(subject.mounted).to.be.falsey;
  });

  it('initializes the formSelector with the given selector', () => {
    expect(subject.$form).to.deep.equal($(selector));
  });

  describe('when mounted', () => {
    beforeEach(() => {
      sinon.spy(subject.$form, 'on');
      subject.mountComponent();
    });

    afterEach(() => {
      subject.$form.on.restore();
      subject.unmountComponent();
    });

    it('mounts the component', () => {
      expect(subject.mounted).to.be.truthy;
    });

    it('mounts the component', () => {
      expect(window.onpopstate).to.equal(subject._onPopState);
    });

    it('binds the form change event', () => {
      expect(subject.$form.on).to.have.been.calledWith('change', 'input, select', subject._onFormChange);
    });

    describe('on form change event', () => {
      let stub = null;

      beforeEach(() => {
        stub = sinon.stub(subject.$form, 'submit');
      });

      it('form is submitted', () => {
        $(selector).find('input[name=order_start_time][value=desc]').trigger('change');

        expect(stub).to.have.been.calledOnce;
      })

      it('sets the onpopostate callback', () => {
        sinon.stub(subject.$form, 'serialize').returns('order_start_time=desc')
        $(selector).find('input[name=order_start_time][value=desc]').trigger('change');

        expect(window.history.pushState).to.have.been.calledWith(null, null, '/filters?order_start_time=desc');
      });
    });

    describe('onpopstate event', () => {
      beforeEach(() => {
        sinon.stub(subject.$form, 'submit');
      });

      it('clears the form data', () => {
        let clearFormSpy = sinon.spy(subject, '_clearForm');

        window.onpopstate();

        expect(clearFormSpy).to.have.been.called;
      });

      it('sets the correct form fields based on the current location', () => {
        sinon.stub(subject, '_getLocation').returns('/filters?order_start_time=desc&scope_id[]=1&scope_id[]=2&filter[category_id]=2')

        window.onpopstate();

        expect($(selector).find('select').val()).to.equal('2');
        expect($(selector).find('input[name=order_start_time][value=desc]').attr('checked')).to.be.truthy;
        expect($(selector).find('input[name=order_start_time][value=asc]').attr('checked')).to.be.falsey;
        expect($(selector).find('input[name=scope_id][value=1]').attr('checked')).to.be.truthy;
        expect($(selector).find('input[name=scope_id][value=2]').attr('checked')).to.be.truthy;
        expect($(selector).find('input[name=scope_id][value=3]').attr('checked')).to.be.falsey;
      });
    });
  });

  describe('when unmounted', () => {
    beforeEach(() => {
      sinon.spy(subject.$form, 'off');
      subject.mountComponent();
      subject.unmountComponent();
    });

    afterEach(() => {
      subject.$form.off.restore();
    })

    it('mounts the component', () => {
      expect(subject.mounted).to.be.falsey;
    });

    it('unbinds the form change event', () => {
      expect(subject.$form.off).to.have.been.calledWith('change', 'input, select', subject._onFormChange);
    });

    it('removes the onpopostate callback', () => {
      expect(window.onpopstate).not.to.exist;
    });
  });

  afterEach(() => {
    $(selector).remove();
  })
});
