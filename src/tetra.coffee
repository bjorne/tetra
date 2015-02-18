{docopt} = require('docopt')
winston = require('winston')
path = require('path')
blessed = require('blessed')
fs = require('fs')
AWS = require('aws-sdk')

Client = require('./tetra/client')
UI = require('./tetra/ui')
Controller = require('./tetra/controller')

class Tetra
  @version = '0.0.0'
  @usage = """
    Usage:
      tetra [<bucket>]
      tetra -h | --help | --version
    """
  constructor: (@argv) ->
  run: ->
    @docopt = docopt(@constructor.usage, argv: @argv[2..], help: true, version: @constructor.version)

    if fs.existsSync path.resolve(__dirname, '../log')
      winston.add(winston.transports.File, filename: path.resolve(__dirname, '../log/tetra.log'), json: false)
    winston.remove(winston.transports.Console)

    AWS.config.update
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_DEFAULT_REGION

    s3Client = new AWS.S3()
    client = new Client(winston, s3Client)
    ui = new UI(winston, blessed)
    controller = new Controller(winston, ui, client, @docopt['<bucket>'])
    controller.run()

module.exports = Tetra
