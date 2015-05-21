angular.module 'app.filters', []
.filter 'mask', ->
  (input, mask, isEnabled) ->
    isEnabled = if not isEnabled? then true else isEnabled
    return input if not isEnabled
    mask = "*" if not mask?
    mask.repeat input.length