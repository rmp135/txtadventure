angular.module 'Settings'
.directive 'listcell', ["$timeout", ($timeout) ->
  return {
    restrict: "E"
    scope: {click:"=", clickable:"="}
    link:(scope, el, attrs) ->
      console.log "bound to element #{el}"
      scope.clickable ? false
      e = angular.element(el)[0]
      if scope.clickable
        e.onclick = ->
          el.addClass 'clicked'
          $timeout ->
            el.removeClass 'clicked'
          , 100
          do scope.click if typeof scope.click is "function"
  }
]