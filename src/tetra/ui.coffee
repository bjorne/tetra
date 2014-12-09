{EventEmitter} = require('events')
_s = require('underscore.string')
path = require('path')

class UI
  constructor: (@logger, blessed) ->
    @screen = blessed.screen()
    @fileList = new UI.FileList(blessed, @logger, @screen)
    @loader = blessed.loading
      parent: @screen
      border:
        type: 'line'
        bg: 'blue'
      style:
        bg: 'blue'
      height: 'shrink'
      width: 'half'
      top: 'center'
      left: 'center'
      label: ' {yellow-fg}Loading...{/yellow-fg} '
      tags: true
      keys: true
      hidden: true
      vi: true
  run: ->
    @screen.key 'q', -> process.exit(0)
    @screen.render()
    @fileList.list.focus()
  render: -> @screen.render()
  load: (str) ->
    @loader.load str
  stopLoad: ->
    @loader.stop()

class UI.FileList extends EventEmitter
  constructor: (blessed, @logger, @parent) ->
    @list = blessed.list
      parent: @parent
      border:
        type: 'line'
      selectedBg: 'blue'
      width: '100%'
      top: 2,
      bottom: 0
      keys: true
      vi: true
      mouse: true
      scrollbar:
        bg: 'white'
        ch: ' '
    @reset()

    @list.on 'select', (item) =>
      index = @list.getScroll()
      item = @items[index]
      if item
        @logger.info 'select', item
        @emit 'select', item

    @list.key 'u', =>
      @list.select 0
  reset: ->
    @items = []
    @list.setItems []

  setItems: (list) ->
    @items = list
    @logger.info list
    @list.setItems list.map @_renderItem.bind(@)
    # @parent.render()

  _renderItem: (item) ->
    return item.message if item.type == 'message'
    @logger.info item
    fileMode = item.mode or item.type[0]
    [fileMode, ' ', _s.lpad(item.size,12), ' ', path.basename(item.path), if item.type == 'directory' then '/' else ''].join('')

module.exports = UI
