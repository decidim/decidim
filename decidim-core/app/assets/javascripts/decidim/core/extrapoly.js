// IE11 fix
// For some reason this is not applied early enough causing IE11 to crash some
// core scripts during load time.
if (typeof NodeList.prototype.forEach !== "function") {
  NodeList.prototype.forEach = Array.prototype.forEach;
}
