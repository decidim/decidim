import { shallow, mount } from 'enzyme';
import * as chai from 'chai';
import * as chaiEnzyme from 'chai-enzyme';
const { expect } = chai;

import * as React from 'react';

import Icon from './icon.component';

chai.use(chaiEnzyme());

describe("<Icon /", () => {
  beforeEach(() => {
    window.DecidimComments = {
      assets: {
        'icons.svg': '/assets/icons.svg'
      }
    };
  })

  // describe("if navigator user agent is not PhantomJS", () => {
  //   let currentNavigator: any = null;

  //   beforeEach(() => {
  //     currentNavigator = window.navigator;
  //     window.navigator = {
  //       userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36"
  //     };
  //   });

  //   it("should render a svg with class defined by prop className", () => {
  //     const wrapper = shallow(<Icon name="icon-thumb-down" />);
  //     expect(wrapper.find('svg.icon-thumb-down')).to.be.present();
  //   });

  //   it("should render a svg icon using the 'icons.svg' url and name", () => {
  //     const wrapper = shallow(<Icon name="icon-thumb-up" />);
  //     expect(wrapper.find('svg use')).to.have.attr('xlink:href').equal('/assets/icons.svg#icon-thumb-up');
  //   });

  //   afterEach(() => {
  //     window.navigator = currentNavigator;
  //   });
  // });

  it("should render a simple span with the icon name", () => {
    const wrapper = shallow(<Icon name="icon-thumb-up" />);
    expect(wrapper.find('span')).to.have.text('icon-thumb-up');
  });

  it("should have a default prop iconExtraClassName with value 'icon--before'", () => {
    const wrapper = mount(<Icon name="icon-thumb-up" />);
    expect(wrapper).to.have.prop('iconExtraClassName').equal('icon--before');
  });

  it("should render the svg with an extra class defined by iconExtraClassName", () => {
    const wrapper = mount(<Icon name="icon-thumb-up" iconExtraClassName="icon--small" />);
    expect(wrapper.find('.icon--small')).to.be.present();
  });
});
