Controller = require('../../src/tetra/controller')

{EventEmitter} = require('events')
{Promise, defer} = require('rsvp')

describe 'Controller', ->
  def 'logger', ->
    info: ->
  def 'ui', ->
    run: ->
    render: ->
    load: ->
    stopLoad: ->
    fileList: do ->
      f = new EventEmitter
      f.setItems = ->
      f
  def 'client', ->
    list: -> defer().promise
    stream: -> defer().promise
  subject -> new Controller(@logger, @ui, @client)

  describe '#run', ->
    it 'runs the UI', (done) ->
      @ui.run = done
      @subject.run()

    it 'sets the UI file list to loading before making client request', (done) ->
      @ui.load = (msg) ->
        msg.should.match(/list/i)
        done()
      @subject.run()

    it 'renders the result from the client request of the root', (done) ->
      deferred = defer()
      @client.list = (path) ->
        path.should.equal('')
        deferred.promise
      @subject.run()
      @ui.fileList.setItems = (items) ->
        items.should.have.length(2)
        done()
      deferred.resolve([1,2])

    it 'asks client to list when selecting directory', (done) ->
      @subject.run()
      @client.list = (path) ->
        path.should.equal('bar/')
        done()
        defer().promise
      @ui.fileList.emit 'select', { type: 'directory', path: 'bar/' }

    it 'does not ask client to list when selecting file', (done) ->
      @subject.run()
      @client.list = ->
        done('client#list called but not expected')
      @ui.fileList.emit 'select', { type: 'file', path: 'bar' }
      done()
