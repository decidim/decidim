const CONTROLLER_REGISTRY = {};

export default class MapControllerRegistry {
  static getController(mapId) {
    return CONTROLLER_REGISTRY[mapId];
  }

  static setController(mapId, map) {
    CONTROLLER_REGISTRY[mapId] = map;
  }

  static findByMap(map) {
    return Object.values(CONTROLLER_REGISTRY).find((ctrl) => {
      return ctrl.getMap() === map;
    });
  }
}
