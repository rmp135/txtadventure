#/*global describe */
#/*global it */
#/*global expect */
#/*global beforeEach */
#/*global angular */
#(function() {
  #describe('Services Test', function() {
#
    #var titleService;
#
    #beforeEach(function() {
      #angular.module('testApp');
    #});
#
    #beforeEach(inject(function() {
      #var $injector = angular.injector(['testApp']);
      #titleService = $injector.get('titleService');
    #}));
#
    #it('is very true', function(){
        #titleService.setTitles('title', 'subtitle', 'pageTitle', 'pageSubtitle');
#
      #var output = titleService.titles;
      #expect(output).toEqual({ title:'title', subtitle:'subtitle', pageTitle:'pageTitle', pageSubtitle:'pageSubtitle' });
    #});
#
  #});
#}());

describe 'tests', ->
  messageService= null
  beforeEach ->
    angular.module 'app'
  beforeEach inject ->
    $injector = angular.injector ['ngMock', 'ng', 'app']
    messageService = $injector.get 'messageService'
  it 'should be true', ->
    expect(true).toBe true
    