PageObject = require './PageObject'


class Form extends PageObject
  ###
  Base class for page-objects with form
  ###

  # submit button selector
  submitButton: ''
  submitButtonWait: ''


  init: ->
    ###
    Initializing
    ###
    super
    @submitButton = @browser.element(@submitButton) if @submitButton
    @submitButtonWait = @browser.element(@submitButtonWait) if @submitButtonWait


  submit: ->
    @submitButton.ready()
    @submitButton.click()
    @submitButtonWait.waitNotPresent() if @submitButtonWait



module.exports = Form
