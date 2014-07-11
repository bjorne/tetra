{spawn} = require 'child_process'

class Controller
  constructor: (@logger, @ui, @client) ->
  run: ->
    @ui.run()
    @_list('')
    @ui.fileList.on 'select', (item) =>
        switch item.type
          when 'directory'
            @_list(item.path)

  _list: (path) ->
    if path?
      @lastPath = path
    else
      path = @lastPath
    @ui.load('Listing prefix...')
    @ui.render()
    list = @client.list(path)
    list.then (items) =>
      @ui.stopLoad()
      @ui.fileList.setItems items
      @ui.render()
    , (err) =>
      @logger.info 'Rejected!', err

module.exports = Controller
