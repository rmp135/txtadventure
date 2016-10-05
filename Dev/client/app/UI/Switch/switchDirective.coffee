.directive 'switch', ->
  return {
    restrict:'E'
    transclude:true
    replace:true
    templateUrl:'partials/switchPartial.html'
    scope: {click:"=", enabled:"="}
    link:(scope, el, attrs) ->
      scope.enabled = scope.enabled ? false
      el.on 'click', ->
        scope.$apply -> scope.enabled = not scope.enabled
        scope.click scope.enabled if typeof scope.click is "function"
  }