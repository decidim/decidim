import { shallow } from 'enzyme';
import { I18n }    from 'react-i18nify';
import moment      from 'moment';

import Application from './application.component';

describe('<Application />', () => {
  afterEach(() => {
    I18n.setLocale('en');
  });

  it("should set I18n locale to locale prop", () => {
    sinon.spy(I18n, 'setLocale');
    const locale = "ca";
    shallow(
      <Application locale={locale}>
        <div>My application</div>
      </Application>
    );
    expect(I18n.setLocale).to.have.been.calledWith(locale);
  });

  it("should set moment locale to locale prop", () => {
    sinon.spy(moment, 'locale');
    const locale = "ca";
    shallow(
      <Application locale={locale}>
        <div>My application</div>
      </Application>
    );
    expect(moment.locale).to.have.been.calledWith(locale);
  });
});
