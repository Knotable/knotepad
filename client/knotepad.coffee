showLoginForm = ->
  $form_modal = $('.user-modal')
  $form_modal.addClass('is-visible')
  $form_modal.find('#login-username').focus()



Template.knotePad.events


  'keyup .new-knote-title': (event) ->
    title = $(event.currentTarget).val()
    length = title.length
    if length > 0
      $('.post-button').attr('disabled', false)
    else
      $('.post-button').attr('disabled', true)
    if length >= 150
      $('.new-knote-body').focus()


  'click .redirect-to-knotable': (e) ->
    token = amplify.store loginToken
    remoteHost = Meteor.settings.public.remoteHost
    if remoteHost[-1] is '/'
      tokenSuffix = "loginToken/#{token}"
    else
      tokenSuffix = "/loginToken/#{token}"
    remoteUrl = "http://" + Meteor.settings.public.remoteHost + tokenSuffix
    if not remoteUrl.match('http://')
      remoteUrl = 'http://' + remoteUrl
    console.log remoteUrl
    window.location = remoteUrl

  'click .login-button':  (e) ->
    return if Meteor.userId()
    showLoginForm()


  'click .post-button': (e, template) ->
    if not Meteor.userId()
      showLoginForm()
    else
      user = Meteor.user()
      subject = $("#header .subject").val()
      title = $(".new-knote-title").val()
      body = $(".new-knote-body").html()

      requiredTopicParams =
        userId: Meteor.userId()
        participator_account_ids: []
        subject: subject
        permissions: ["read", "write", "upload"]

      $postButton = $(e.currentTarget)
      $postButton.val('...')

      if template.data?.pad?._id
        topicId = template.data.pad._id

        requiredKnoteParameters =
          subject: subject
          body: body
          topic_id: topicId
          userId: user._id
          name: user.username
          from: user.emails[0].address
          isMailgun: false

        optionalKnoteParameters =
          title: title
          replys: []
          pinned: false

        Meteor.remoteConnection.call 'add_knote', requiredKnoteParameters, optionalKnoteParameters, (error, result) ->
          $postButton.val('Post')
          if error
            console.log 'add_knote', error
          else
            $(".new-knote-title").val('')
            $(".new-knote-body").html('')
      else
        Meteor.remoteConnection.call "create_topic", requiredTopicParams, (error, result) ->
          if error
            console.log 'create_topic', error
            $postButton.val('Post')
          else
            topicId = result

            requiredKnoteParameters =
              subject: subject
              body: body
              topic_id: topicId
              userId: user._id
              name: user.username
              from: user.emails?[0]
              isMailgun: false

            optionalKnoteParameters =
              title: title
              replys: []
              pinned: false
            Meteor.remoteConnection.call 'add_knote', requiredKnoteParameters, optionalKnoteParameters, (error, result) ->
              $postButton.val('Post')
              if error
                console.log 'add_knote', error
              else
                $(".new-knote-title").val('')
                $(".new-knote-body").html('')

            Router.go 'knotePad', padId: topicId



Template.knotePad.helpers


  username: ->
    Meteor.user()?.username


  hasLoggedIn: ->
    Boolean Meteor.userId()


  contentEditableSubject: ->
    subject = moment().format "MMM Do"
    attrs = [
      "class='subject'"
    ]
    html = "<div #{attrs.join(' ')}>#{subject}</div>"
    return new Spacebars.SafeString html

Template.knote.events


  'mouseenter .knote': (e) ->
    $(e.currentTarget).find('.knote-date').show()



  'mouseleave .knote': (e) ->
    $(e.currentTarget).find('.knote-date').hide()


Template.knote.helpers
  contact: ->
    Contacts.findOne({emails: @from})




Template.participatorsAvatar.helpers
  participators: ->
    userAccountId = UserAccounts.findOne({user_ids: Meteor.userId()})?._id
    accountIds = _.difference @pad.participator_account_ids, [userAccountId]
    contacts = Contacts.find({belongs_to_account_id: {$in: accountIds}}).fetch()
    userContact = Contacts.findOne({account_id: userAccountId, type: 'me'})
    contacts.push userContact
    return contacts



Template.participatorsAvatar.events
  'click .add-contact': (event, template) ->
    $('.addContactPopup').lightbox_me(centered: true)



Template.addContactPopupBox.events
  'click .add-new-users': (event, template) ->
    emails = template.$('.emails').val()
    emails = emails.split(',')
    emails = _.select emails, (email) ->
      email.match(/[\w-]+@([\w-]+\.)+[\w-]+/)
    emails = _.map emails, (email) -> $.trim(email)
    if emails.length
      Meteor.remoteConnection.call 'addContactsToThread', template.data.pad._id, emails, (error, result) ->
        if error
          console.log 'ERROR: addContactsToThread', error
        else
          template.$('a.btn-close').click()
