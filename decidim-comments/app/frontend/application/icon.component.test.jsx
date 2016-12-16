import { shallow } from 'enzyme';

import Icon        from './icon.component';

describe("<Icon /", () => {
  beforeEach(() => {
    window.DecidimComments = {
      assets: {
        'icons.svg': '/assets/icons.svg'
      }
    };
  })

  describe("if navigator user agent is not PhantomJS", () => {
    let currentNavigator = null;

    beforeEach(() => {
      currentNavigator = window.navigator;
      window.navigator = {
        userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36"
      };
    });

    it("should render a svg with class defined by prop className", () => {
      const wrapper = shallow(<Icon name="icon-thumb-down" />);
      expect(wrapper.find('svg.icon-thumb-down')).to.be.present();    
    });

    it("should render a svg icon using the 'icons.svg' url and name", () => {
      const wrapper = shallow(<Icon name="icon-thumb-up" />);
      expect(wrapper.find('svg use')).to.have.attr('xlink:href').equal('/assets/icons.svg#icon-thumb-up');
    });

    afterEach(() => {
      window.navigator = currentNavigator;
    });
  });

  it("should render a simple span with the icon name", () => {
    const wrapper = shallow(<Icon name="icon-thumb-up" />);
    expect(wrapper.find('span')).to.have.text('icon-thumb-up');
  });
});
