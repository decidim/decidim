import { shallow } from 'enzyme';
import { I18n }    from 'react-i18nify';

import Application from './application.component';

describe('<Application />', () => {
  afterEach(() => {
    I18n.setLocale('en');
  });

  it("should set I18n locale to session locale", () => {
    sinon.spy(I18n, 'setLocale');
    const session = { locale: "ca" };
    shallow(
      <Application session={session}>
        <div>My application</div>
      </Application>
    );
    expect(I18n.setLocale).to.have.been.calledWith(session.locale);
  });
});
