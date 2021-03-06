@CHAR_LIMITATION_IN_KNOTE_TITLE = 150



@PadsListHelper =

  scrollAction: ->
    currentScroll = $('.padList').scrollTop()
    sharePadBtn = $('#header .share-pad')

    if currentScroll > 0
      $('#header').addClass('scrolling')
    else
      $('#header').removeClass('scrolling')

    if currentScroll > 180
      $('.show-compose').removeClass("invisible")
    else
      $('.show-compose').addClass("invisible")

    $currentPadItem = $('.padItem').filter( ->
      $pad = $(@)
      top = 80
      $pad.position().top < top
    ).last()

    if $currentPadItem.length
      subject = $currentPadItem.data('subject')
      id = $currentPadItem.data('id')
      sharePadBtn.show()
    else
      subject = PadsListHelper.todaySubject()
      id = $('#header .title').data('latest-id')
      unless id
        sharePadBtn.hide()
    $('#header .subject').text subject
    $('#header .share-pad').attr 'data-id', id
    $('#header .redirect-to-knotable').attr 'href', UrlHelper.getPadUrlFromId(id)



  todaySubject: ->
    user = AppHelper.currentContact()
    date = moment().format "MMM Do"
    if user
      return user.username + '\'s Knoteup for ' + date
    else
      return date



  storeEditedContent: (editKnote) ->
    amplify.store "knote", editKnote



  restoreEditedContent: ->
    storedKnote = amplify.store("knote")
    return if _.isEmpty storedKnote
    $(".compose .knote-title").html(storedKnote.title)
    $(".compose .knote-body").html(storedKnote.body).show() unless _.isEmpty(storedKnote.body)



  resetEditedContent: ->
    amplify.store 'knote', null



  getSortedKnotes: (padId) ->
    {
      unarchived: knotesRepository.find({topic_id: padId, archived: $ne: true}, {sort: {order: -1, timestamp: -1} }).fetch()
      archived: knotesRepository.find({topic_id: padId, archived: true, is_fake: $ne: true}, {sort: {order: -1, timestamp: -1} }).fetch()
    }



  listenToTitlePaste: (jQueryEvent, templateInstance) ->
    AppHelper.pasteAsPlainTextEventHandler(jQueryEvent)
    currentText = $(jQueryEvent.currentTarget).text()
    content = PadsListHelper.splitKnoteTitle(currentText)
    if content.bodyText
      body = templateInstance.find('.knote-body')
      PadsListHelper.insertContentIntoTitleAndBody(jQueryEvent.currentTarget, body, content)



  listenToTitleInput: (jQueryEvent, templateInstance) ->
    unless jQueryEvent.metaKey or jQueryEvent.ctrlKey
      titleText = $(jQueryEvent.currentTarget).text()
      content = PadsListHelper.splitKnoteTitle titleText
      if content.bodyText
        body = templateInstance.find('.knote-body')
        PadsListHelper.insertContentIntoTitleAndBody jQueryEvent.currentTarget, body, content



  splitKnoteTitle: (text) ->
    if _.size(text) > CHAR_LIMITATION_IN_KNOTE_TITLE
      result =
        titleText: text.substr(0, CHAR_LIMITATION_IN_KNOTE_TITLE)
        bodyText: text.substr(CHAR_LIMITATION_IN_KNOTE_TITLE)
    else
      result = titleText: text
    result



  insertContentIntoTitleAndBody: (titleElement, bodyElement, content) ->
    cursor = SelectionTextHelper.getSelectionData()
    $(titleElement).text(content.titleText)
    SelectionTextHelper.setCursorAt(cursor.pos, titleElement)
    if bodyElement
      $(bodyElement).prepend(content.bodyText).show()
      if cursor.pos > content.titleText.length
        $(bodyElement).focus()
        SelectionTextHelper.setCursorAt(content.bodyText.length, bodyElement)



  moveFocusToBodyIfNecessary: (jQueryEvent, templateInstance) ->
    return if (jQueryEvent.shiftKey or jQueryEvent.ctrlKey) and jQueryEvent.keyCode is 13
    if jQueryEvent.keyCode is 13 or jQueryEvent.keyCode is 10
      jQueryEvent.preventDefault()
      text = $(jQueryEvent.currentTarget).text()
      templateInstance.$('.knote-body').removeClass('hidden').show().focus() unless _.isEmpty(text)
      return false



  leftSideMessage: (template, type) ->
    return if !template.knotes
    unarchived = template.knotes.unarchived.length
    archived = template.knotes.archived.length
    total = unarchived + archived
    half = total / 2
    if total == 1
      text = "That's a start."
      image = "one"
    if total > 1
      text = "Yawn. Too easy."
      image = "more-one"
    if total > 2
      text = "Not bad."
      image = "more-two"
      if total > 3
        text = "Getting there.."
        image = "more-three"
      if total > 4
        text = "Let's get cracking!"
        image = "more-four"
      if total > 5
        text = "Wow. Busy!"
        image = "more-five"
      if archived >= half
        text = "In the zone."
        image = "half"
      if archived == (total - 1)
        text = "So...close."
        image = "one-more"
      if total > 3 and unarchived == 0
        text = "Great job!"
        image = "success"
    if moment().endOf('day').fromNow() < 8 && unarchived > 3
      text = "Its getting late!"
      image = "sleepy"
    if type == "image"
      return image
    if type == "text"
      return text



  initKnoteDraggable: ->
    options =
      items: '.knote'
      cancel: '.in-edit'
      cursorAt:
        top: 0
        left: 0
      scrollSensitivity: 100
      handle: '.knote-header'
      placeholder: 'knote-placeholder'
      forcePlaceholderSize: true
      appendTo: '.pad'
      update: (e, ui) ->
        knote = Knotes.findOne ui.item.data('id')
        PadsListHelper.updateOrder(knote.topic_id)
      start: (e, ui) ->
        ui.item.addClass('sorting')
        Session.set('isKnoteDroppabe', true)
      stop: (e, ui) ->
        ui.item.removeClass('sorting')
        Session.set('isKnoteDroppabe', false)

    $container = $(".unarchived-knotes")
    $container
      .sortable(options)



  updateOrder: (topicId) ->
    return if !topicId
    $knotes = $("[data-topic-id='" + topicId + "']")
    length = $knotes.length
    return if length is 0
    Session.set 'knotesNum', length
    order = 0
    _.each $knotes, (k) ->
      id = $(k).data('id')
      order--
      Knotes.update({_id: id}, {$set: { order : order }})



  knotesNumToText: (knotesNum) ->
    words = ['','first','second','third','fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth',
    'tenth', 'eleventh', 'twelveth', 'thirteenth', 'fourteenth', 'fifteenth', 'sixteenth', 'seventeenth', 'eighteenth', 'nineteenth']
    return words[knotesNum + 1]


  getTextFromHtml: (html) ->
    $('<div>').append(html).text()
