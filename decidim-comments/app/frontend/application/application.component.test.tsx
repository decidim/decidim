import { shallow } from "enzyme";
import * as React from "react";

import Application from "./application.component";

const { I18n } = require("react-i18nify");

describe("<Application />", () => {
  afterEach(() => {
    I18n.setLocale("en");
  });

  it("should set I18n locale to locale prop", () => {
    spyOn(I18n, "setLocale");
    const locale = "ca";
    shallow(
      <Application locale={locale}>
        <div>My application</div>
      </Application>
    );
    expect(I18n.setLocale).toHaveBeenCalledWith(locale);
  });
});
