angular.module 'Terminal'
.directive 'terminal', ($interval, $timeout) ->
    return {
        restrict:'E'
        transclude:true
        #controller: 'TerminalController'
        templateUrl: 'partials/terminalDirectivePartial.html'
        replace:true
        compile: (tElement, tAttrs, transclude) ->
            return {
                pre: (scope, element, attrs, controller) ->
                post: ($scope, element, attrs, controller) ->
                  output = angular.element('#output')[0]
                  cursor = angular.element('#cursor')
                  input = angular.element('#target')
                  viewport = angular.element('#terminal-viewport')[0]
                  
                  ctrlDown = false
                  
                  input.on 'keypress', (e) ->
                    if $scope.flashing
                      if e.which is 13 and $scope.flashing
                        $scope.execute $scope.commandLine

                  input.on 'focus', ->
                    $scope.flashing = true
                  
                  input.on 'blur', ->
                    $scope.flashing = false
                      
                  element.on 'click', (e) ->
                    input.focus()
                    $scope.flashing = true

                  $interval ->
                      if $scope.flashing
                          cursor.toggleClass 'hidden'
                  , 500
                  
                  scrollToTop = ->
                    #console.log viewport.scrollTop
                    if viewport.scrollTop isnt 0
                      $timeout ->
                        #console.log viewport.scrollTop
                        viewport.scrollTop = viewport.scrollHeight
                      , 0
                  
                  #$scope.$watchCollection (-> $scope.history), (newValues, oldValues) ->
                    #return if newValues?.length==0
                    #$scope.flashing = false
                    #$scope.commandLine = ''
                    #echo newValues[newValues.length-1], ->
                        #$scope.flashing = true
                        #input.focus()

                  createLine = ->
                    line = document.createElement('pre')
                    output.appendChild line
                    return line
                      
                  scramble = (text, options, callback, line) ->
                    line = createLine() if not line?
                    config = angular.extend {
                      digits:'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                      cycles:10
                      delay: 50
                      }, options
                  
                    cyclesremaining = config.cycles
                    _randomDigit = ->
                        config.digits[Math.round Math.random()*(config.digits.length-1)]

                    _scramble = (text, i) ->
                      $timeout ->
                        if i is text.length
                          scrollToTop()
                          callback() if callback?
                        else
                          if cyclesremaining is 0
                            line.textContent = line.textContent.substr(0, i) + text[i] + line.textContent.substr(i+1)
                            line.textContent[i] = text[i]
                            cyclesremaining = config.cycles
                            _scramble text, i+1
                          else
                            line.textContent = line.textContent.substr(0, i) + _randomDigit() + line.textContent.substr(i+1)
                            cyclesremaining--
                            _scramble text, i

                      , config.delay
                    _scramble text, 0
                    
                  blink = (text, callback, line) ->
                    line = createLine() if not line?
                    _blink = (text, callback, line, i) ->
                      $timeout ->
                        if i < text.length
                          line.textContent += text[i]
                          _blink text, callback, line, i+1
                        else
                          scrollToTop()
                          callback() if callback?
                      ,20
                    _blink text, callback, line, 0
                  
                  echoMultiple = (lines, options, callback) ->
                    config = angular.extend {
                      delay:0
                    }, options
                    _echoMultiple = (lines, i, callback) ->
                      $timeout ->
                        if i < lines.length
                          if i < lines.length-1
                            blink lines[i], (-> _echoMultiple lines, i+1, callback)
                          else
                            blink lines[i], callback
                        else
                          scrollToTop()
                          callback()
                      , config.delay
                    _echoMultiple lines, 0, callback
                        
                  echo = (text, callback) ->
                    line = createLine()
                    line.textContent = text
                    scrollToTop()
                    $scope.commandLine = ''
                    $scope.$digest()
                    callback() if callback?

                  rescramble = (text, options, callback) ->
                    line = createLine()
                    config = angular.extend {
                      digits:'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                      }, options
                    scrambledtext = []
                    scrambledtext.push(config.digits[Math.round(Math.random()*(text.length-1))]) for t in text
                    blink scrambledtext, ->
                      scramble text, options, callback, line
                    , line

                  $scope.accessor =
                    echo: echo
                    echoMultiple: echoMultiple
                    scramble: scramble
                    rescramble: rescramble
                    blink: blink
            }
    }