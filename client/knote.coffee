Template.knote.events
  'mouseenter .knote': (e) ->
    $(e.currentTarget).find('.knote-date').show()

  'mouseleave .knote': (e) ->
    $(e.currentTarget).find('.knote-date').hide()



Template.knote.helpers
  contact: ->
    Contacts.findOne({emails: @from})
