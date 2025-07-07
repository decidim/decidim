import PasswordToggler from "src/decidim/password_toggler";

const initializeApiSecretToggler = () => {
  const apiUserPasswords = document.querySelectorAll(".api-user-secret");
  apiUserPasswords.forEach((userPassword) => {
    new PasswordToggler(userPassword).init();
  })
}

document.addEventListener("DOMContentLoaded", () => {
  initializeApiSecretToggler();
});
