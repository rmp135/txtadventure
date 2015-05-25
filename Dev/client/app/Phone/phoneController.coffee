angular.module 'Phone'
.controller 'PhoneController', ($scope, $stateParams) ->
  console.log 'phone initialised'
  
  if $stateParams.number.length
    $scope.number = $stateParams.number
    $('#backbtn').children().css('display','')
  else 
    $scope.number = ""
    $('#backbtn').children().css('display','none')

  #Hide back button on first load.
  addPhoneEventHandler = (el) ->
    el.addEventListener 'mousedown', (e) ->
      numpad = $('#numberoutput')[0]
      $scope.number = $scope.number + e.target.innerHTML
      $('#backbtn').children().css('display','')
      $scope.$apply()

  addPhoneEventHandler x for x in $('.numkey')
  
  $('#backbtn').children()[0].addEventListener 'mousedown', ->
      $scope.number = ""
      $('#backbtn').children().css('display','none')
      $scope.$apply()

