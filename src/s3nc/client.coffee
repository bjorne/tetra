{defer} = require('rsvp')
_path = require('path')

class Client
  constructor: (@logger, @s3Client) ->
  list: (path) ->
    deferred = defer()
    @logger.info 'path before', path
    path = _path.normalize('/'+path).replace(/^\//, '') if path != ''
    @logger.info 'path after', path
    @s3Client.list prefix: path, delimiter: '/', (err, data) =>
      if err
        @logger.warn "Client error: #{err}"
        return deferred.reject(err)

      @logger.info 'client data', data
      list = []
      data.CommonPrefixes?.forEach (prefix) ->
        return if prefix.Prefix == '/'
        list.push
          type: 'directory'
          path: prefix.Prefix
      data.Contents.forEach (file) =>
        list.push
          type: 'file'
          path: file.Key
          mode: file.StorageClass[0]
          size: file.Size

      if path != ''
        list.unshift
          type: 'directory'
          path: path + '../'

      deferred.resolve(list)
    deferred.promise

module.exports = Client
