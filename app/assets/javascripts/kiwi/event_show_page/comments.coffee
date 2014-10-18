FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->

  @create = (options) ->
    @instance = new Comments.Controller options
    @instance.fetch()
    return @instance

  class Comments.Controller extends Marionette.Controller
    initialize: (options) =>
      @layout = new Comments.Layout
        el: options.domLocation

      @username = App.request('currentUser').get('username')
      @event = options.event

      @on 'comment_count:changed', (comment_delta) =>
        @event.set('comment_count', @event.get('comment_count') + comment_delta)

      @collection = @event.comments

      @commentViews = {}
      @commentsListView = new Comments.CommentsListView(collection: @collection)
      @commentsListView.on 'before:item:added', @registerCommentView
      @commentsListView.on 'itemview:dom:refresh', @showReplies

      @layout.on 'render', () =>
        @commentBox = @openReply(@layout.commentNewRegion, @collection)
        @layout.commentListRegion.show(@commentsListView)

      #Put its root view into the dom
      @layout.render()

    fetch: () =>
      @collection.fetchForEvent()

    registerCommentView: (commentView) =>
      @commentViews[commentView.model.cid] = commentView

      commentView.setModeratorMode(App.request('isModerator'))
      commentView.setCurrentUser(App.request('currentUser').get('username'))

      @listenTo commentView, 'click:reply', @openReplyFromView
      @listenTo commentView, 'click:delete', @deleteComment

    showReplies: (commentView) =>
      replyViews = new Comments.CommentsListView collection: commentView.model.replies
      @listenTo replyViews, 'before:item:added', @registerCommentView
      @listenTo replyViews, 'itemview:dom:refresh', @showReplies
      commentView.repliesRegion.show replyViews

    openReplyFromView: (args) =>
      @openReply(args.view.replyBoxRegion, args.model.replies)

    openReply: (region, collection) =>
      return if not App.request('currentUser').get('logged_in')
      replyBox = new Comments.ReplyBox({ collection: collection })
      @listenTo replyBox, 'click:add:comment', @commentFromView
      region.show replyBox
      replyBox

    commentFromView: (args) =>
      view = args.view
      collection = args.collection
      @comment(view.commentValue(), App.request('currentUser').get('username'), collection)
      view.clearInput()

    comment: (message, user, list = @collection) =>
      comment = list.comment(message, user)
      @.trigger('comment_count:changed', 1)
      comment

    commentViewByModel: (comment) =>
      @commentViews[comment.cid]

    deleteComment: (args) =>
      comment = args.model.deleteComment()
      @.trigger('comment_count:changed', -1)
      comment

    onClose: () =>
      @layout.close()

  #Pulls together all the things
  class Comments.Layout extends Marionette.Layout
    template: FK.Template('event_show_page/comments')
    regions:
      commentNewRegion: '#comment-new'
      commentListRegion: '#comment-list'

  #Renders the text box to create a new comment
  #Can be used either to create a top level comment or to reply
  class Comments.ReplyBox extends Marionette.ItemView
    template: FK.Template('event_show_page/comments_reply_box')
    className: 'reply-box'

    templateHelpers: () =>
      return {
        cancelButton: @collection.hasParent()
      }

    events:
      'keyup textarea': 'writingComment'
      'click [data-action="cancel"]': 'close'

    triggers:
      'click [data-action="comment"]': 'click:add:comment'

    clearInput: () =>
      if @collection.hasParent()
        @close()
      else
        @$('textarea').val('')
        @enableButton(0)

    commentValue: () =>
      @$('textarea').val()

    writingComment: (e) =>
      @enableButton(@$('textarea').val().length)

    enableButton: (numCharacters) =>
      if (numCharacters > 0)
        @$('[data-action="comment"]').removeClass('disabled')
      else
        @$('[data-action="comment"]').addClass('disabled')

    onRender: =>
      @enableButton(0)

    onShow: =>
      if (@collection.hasParent())
        @$('textarea').focus()

  #Renders all the comment and all its replies
  class Comments.CommentSingleView extends Marionette.Layout
    template: FK.Template('event_show_page/comment_single')
    className: 'comment'

    getTemplate: () =>
      return FK.Template('event_show_page/comment_deleted') if @model.get('status') is 'deleted'
      return FK.Template('event_show_page/comment_muted') if @model.get('status') is 'muted'
      return FK.Template('event_show_page/comment_single')

    templateHelpers: () =>
      return {
        canDelete: (@username == @model.get('username')) || @moderatorMode
        message_marked: marked(@model.escape('message'))
        voteCount: @model.netvotesWithMin()
      }

    events:
      'click .fa-caret-up': 'upvote'
      'click .fa-caret-down': 'downvote'
      'click .mute-delete': 'deletePrep'

    regions:
      'replyBoxRegion': '.nested-comments:first > .replybox-region'
      'repliesRegion': '.nested-comments:first > .replies-region'

    triggers:
      'click .reply': 'click:reply'
      'click .mute-delete.btn': 'click:delete'

    upvote: (e) =>
      e.stopPropagation()
      return unless @username
      @model.upvoteToggle()

    downvote: (e) =>
      e.stopPropagation()
      return unless @username
      @model.downvoteToggle()

    deletePrep: (e) =>
      e.stopPropagation()
      $(e.target).addClass('btn btn-danger btn-xs')
      $(e.target).text('Confirm?')
      _.delay(@deleteReset, 5000)

    deleteReset: () =>
      @$('.mute-delete:first').removeClass('btn btn-danger btn-xs')
      @$('.mute-delete:first').text(@muteDeleteText())

    muteDeleteText: () =>
      if @username is @model.get('username')
        'Delete'
      else
        'Mute'

    initialize: =>
      @collection = @model.replies


    updateVotes: =>
      @toggleUpvote()
      return unless @username
      @$('.up-vote:first i.fa-caret-up').removeClass('upvote-marked')
      @$('.up-vote:first i.fa-caret-down').removeClass('downvote-marked')
      @displayVote()

    displayVote: =>
      if @model.get('have_i_upvoted')
        @$('.up-vote:first i.fa-caret-up').addClass('upvote-marked')
      if @model.get('have_i_downvoted')
        @$('.up-vote:first i.fa-caret-down').addClass('downvote-marked')
      @$('.user-comment:first .upvotes').text(@model.netvotesWithMin())

    toggleUpvote: =>
      if @model.netvotes() == 1
        @$('.user-comment:first .upvote-toggle').text('upvote')
      else
        @$('.user-comment:first .upvote-toggle').text('upvotes')

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

    onRender: =>
      @updateVotes()

    modelEvents:
      'change:deleter': 'render'
      'change:muter': 'render'
      'change:have_i_upvoted': 'updateVotes'
      'change:have_i_downvoted': 'updateVotes'

    onShow: () =>
      if not @username
        @$('.reply').tooltip(title: 'Login to reply.')
        @$('.fa-caret-up').tooltip(title: 'Login to upvote.')
        @$('.fa-caret-down').tooltip(title: 'Login to downvote.')
      @$('.tools > .mute-delete').text(@muteDeleteText())

    setCurrentUser: (username) =>
      @username = username

    setModeratorMode: (moderator) =>
      @moderatorMode = moderator

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentSingleView
    className: 'comment-list'

    appendHtml: (collectionView, itemView, index) =>
      return collectionView.$el.prepend(itemView.el) if index is 0
      atIndex = collectionView.$el.children().eq(index)
      return atIndex.before(itemView.el) if atIndex.length
      return collectionView.$el.append(itemView.el)
