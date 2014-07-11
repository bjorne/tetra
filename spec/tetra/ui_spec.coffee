UI = require('../../src/tetra/ui')
{EventEmitter} = require('events')

describe 'UI', ->
  def 'logger', ->
    info: ->
  def 'blessed', ->
    screen: => @screen
    list: => @list
    loading: ->
  def 'screen', ->
    render: ->
    key: ->
  def 'list', ->
    list = new EventEmitter
    list.setItems = ->
    list.key = ->
    list.focus = ->
    list

  subject -> new UI(@logger, @blessed)
  it 'renders the screen initially', (done) ->
    @screen.render = done
    @subject.run()

  it 'binds the q key', (done) ->
    @screen.key = (key, callback) ->
      key.should.equal 'q'
      callback.should.be.a.function
      done()
    @subject.run()

  describe 'UI.FileList', ->
    def 'parent', ->
      {}

    subject ->
      new UI.FileList(@blessed, @logger, @parent)

    it 'creates a blessed list with given parent', (done) ->
      @blessed.list = (options) =>
        options.parent.should.equal(@parent)
        done()
        @list
      @subject

    it 'is empty initially', (done) ->
      @list.setItems = (items) =>
        items.should.eql []
        done()
      @subject

    describe '#setItems', ->
      it 'renders directory item', (done) ->
        @subject
        @list.setItems = (items) ->
          items.should.have.length(1)
          items[0].should.match(/^d\s+bar\//)
          done()
        @subject.setItems [
          type: 'directory'
          path: 'foo/bar/'
        ]

      it 'renders file item', (done) ->
        @subject
        @list.setItems = (items) ->
          items.should.have.length(1)
          items[0].should.match(/^S\s+baz/)
          done()
        @subject.setItems [
          type: 'file'
          path: 'foo/bar/baz'
          mode: 'S'
        ]

    describe '~select', ->
      it 'emits the item which correspond to the selected line', ->
