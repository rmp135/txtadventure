angular.module 'ContactList'
.controller 'ContactListController', ($scope, contactService, contacts) ->
  console.log 'contacts initialised'
  $scope.adding = false
  $scope.contacts = contacts
  
  $scope.deleteContact = (index) ->
    contactService.removeContactWithId $scope.contacts[index].id
    .$promise
    .then ->
      $scope.contacts.splice index, 1
      
  $scope.checkForm = ->
    /^\d+$/.exec($scope.number) is null

  $scope.toggleAdd = ->
    $scope.adding = !$scope.adding
    $scope.number = ""

  $scope.addContact = ->
    contactService.addContact $scope.number
    .$promise
    .then (response) ->
      $scope.contacts.push response
      $scope.error = ''
      $scope.number = ''
    .catch (response) ->
      $scope.error = ''
      $scope.number = ''