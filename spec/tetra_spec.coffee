Tetra = require('../lib/tetra')

{spawn} = require('child_process')
path = require('path')
es = require('event-stream')

describe 'Tetra CLI', ->
  it 'prints usage information when given no arguments', (done) ->
    cmd = spawn path.resolve(__dirname, '../bin/tetra')
    cmd.stdout.pipe es.wait (err, str) ->
      throw err if err
      str.should.match(/^Usage/)
      done()

  it 'returns code 1 when given no arguments', (done) ->
    cmd = spawn path.resolve(__dirname, '../bin/tetra')
    cmd.on 'close', (code) ->
      code.should.equal 1
      done()
