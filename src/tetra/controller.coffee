{spawn} = require 'child_process'

class Controller
  constructor: (@logger, @ui, @client, @s3Bucket) ->
  run: ->
    @ui.run()
    @_list('')
    @ui.fileList.on 'select', (item) =>
        switch item.type
          when 'directory'
            @_list(item.path)
          when 'bucket'
            @s3Bucket = item.name
            @_list('/')

  _list: (path) ->
    if path?
      @lastPath = path
    else
      path = @lastPath
    @ui.load('Listing prefix...')
    @ui.render()

    list = @client.list(path, @s3Bucket)
    list.then (items) =>
      @ui.stopLoad()
      @ui.fileList.setItems items
      @ui.render()
    , (err) =>
      @logger.info 'Rejected!', err

module.exports = Controller
