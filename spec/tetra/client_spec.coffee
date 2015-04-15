Client = require('../../src/tetra/client')

{EventEmitter} = require('events')
{Promise, defer} = require('rsvp')

describe 'Client', ->
  def 'logger', ->
    info: ->
    warn: ->
  def 's3Client', ->
    listObjects: ->
    listBuckets: ->
  subject -> new Client(@logger, @s3Client)

  describe '#list', ->
    it 'passes the path to the underlying client', (done) ->
      @s3Client.listObjects = (options) ->
        options.Prefix.should.equal('foo/')
        options.Delimiter.should.equal('/')
        options.Bucket.should.equal('bar')
        done()
      @subject.list('foo/','bar')

    it 'does not include root prefix', ->
      @s3Client.listObjects = (options, callback) ->
        callback null,
          CommonPrefixes: [
            Prefix: '/'
          ]
          Contents: []
      @subject.list('','foo').should.eventually.be.empty

    it 'transforms prefixes into directory structure', ->
      @s3Client.listObjects = (options, callback) ->
        callback null,
          CommonPrefixes: [
            Prefix: 'foo/'
          ]
          Contents: []
      @subject.list('','bar').should.eventually.eql [
        type: 'directory'
        path: 'foo/'
      ]

    it 'transforms prefixes into file structure', ->
      @s3Client.listObjects = (options, callback) ->
        callback null,
          Contents: [
            Key: 'foo/bar'
            StorageClass: 'STANDARD'
            Size: 123
          ]
      @subject.list('','bar').should.eventually.eql [
        type: 'file'
        path: 'foo/bar'
        mode: 'S'
        size: 123
      ]

    it 'includes parent directory when listing something other than the root', ->
      @s3Client.listObjects = (options, callback) ->
        callback null,
          Contents: []
      @subject.list('bar/','foo').should.eventually.eql [
        type: 'directory'
        path: 'bar/../'
      ]

    it 'rejects the promise if the client returns an error', ->
      err = new Error('damnit')
      @s3Client.listObjects = (options, callback) ->
        callback err, null
      @subject.list('bar/','foo').should.be.rejectedWith(err)
