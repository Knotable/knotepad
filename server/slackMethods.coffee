Meteor.methods
  checkCurrentSlackCredentials: ->
    user = Meteor.user()
    slackAccessToken = user?.services?.slack?.accessToken
    return ok: false, error: 'not logged in slack' unless slackAccessToken
    postData = "token=#{slackAccessToken}"
    result = HTTP.post 'https://slack.com/api/auth.test', query: postData
    return _.pick result.data, 'ok', 'error' if result.data
    return ok: false, error: 'unable to parse the response'



  getListOfSlackChannels: ->
    user = Meteor.user()
    slackAccessToken = user?.services?.slack?.accessToken
    return [] unless slackAccessToken
    postData = "token=#{slackAccessToken}&exclude_archived=1"
    result = HTTP.post 'https://slack.com/api/channels.list', query: postData
    return result.data


  postOnSlack: (title, text, channelId) ->
    check title, String
    check text, String
    check channelId, String
    user = Meteor.user()
    slackAccessToken = user?.services?.slack?.accessToken
    return false unless slackAccessToken
    postData = "token=#{slackAccessToken}&channel=#{channelId}&as_user=true"
    attachments = [{
      fallback: "Posted via KnoteUp",
      color: "#2DACED",
      author_name: "See progress on my queue at Knoteup",
      author_link: "http://quick.knotable.com",
      author_icon: "http://d1wubs3nxxxkxo.cloudfront.net/static/public/images/chome_notification_icon.png",
      title: title,
      text: text
    }]
    postData += "&attachments=#{encodeURIComponent JSON.stringify attachments}"
    result = HTTP.post 'https://slack.com/api/chat.postMessage', query: postData
    return result.data
