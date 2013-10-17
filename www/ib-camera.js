(function() {
  function IBCamera() {};

  IBCamera.prototype.getPicture = function(successCallback, failCallback) {
    cordova.exec(successCallback, failCallback, "CameraPlugin", "getPicture", [true]);
  };

  if(!window.plugins) {
    window.plugins = {};
  }

  if(!window.plugins.ibcameraplugin) {
    window.plugins.ibcameraplugin = new IBCamera();
  }
})();
