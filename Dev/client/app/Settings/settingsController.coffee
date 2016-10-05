angular.module 'Settings'
.controller 'SettingsController', ($scope, userService) ->
  console.log 'settings initialised'
  $scope.user = userService.currentUser