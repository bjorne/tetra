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
          when 'file'
            @_view(item.path)

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

  _view: (path) ->
    @ui.load('Loading file...')
    @ui.render()
    @client.stream(path, @s3Bucket).then (stream) =>
      @ui.stopLoad()
      process.stdin.pause()
      process.stdin.setRawMode false
      p = spawn 'less', ['-'], stdio: ['pipe', process.stdout, process.stderr]
      p.on 'exit', =>
        process.stdin.setRawMode true
        process.stdin.resume()
      stream.pipe(p.stdin)
    , (err) =>
      @logger.info 'stream err', err

module.exports = Controller
