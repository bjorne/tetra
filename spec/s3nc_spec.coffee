S3nc = require('../lib/s3nc')

{spawn} = require('child_process')
path = require('path')
es = require('event-stream')

describe 'S3nc CLI', ->
  it 'prints usage information when given no arguments', (done) ->
    cmd = spawn path.resolve(__dirname, '../bin/s3nc')
    cmd.stdout.pipe es.wait (err, str) ->
      throw err if err
      str.should.match(/^Usage/)
      done()

  it 'returns code 1 when given no arguments', (done) ->
    cmd = spawn path.resolve(__dirname, '../bin/s3nc')
    cmd.on 'close', (code) ->
      code.should.equal 1
      done()
