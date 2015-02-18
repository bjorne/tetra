{defer} = require('rsvp')
_path = require('path')

class Client
  constructor: (@logger, @s3Client) ->
  listObjects: (path, s3Bucket) ->
    deferred = defer()
    @s3Client.listObjects Marker: path, Delimiter: '/', Bucket: s3Bucket, (err, data) =>
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

  listBuckets: ->
    deferred = defer()
    @s3Client.listBuckets (err, data) =>
      if err
        @logger.warn "Client error: #{err}"
        return deferred.reject(err)

      @logger.info 'client data', data
      list = []
      data.Buckets.forEach (bucket) =>
        list.push
          type: 'bucket'
          name: bucket.Name

      deferred.resolve(list)
    deferred.promise

  list: (path, s3Bucket) ->
    @logger.info 'path before', path
    path = _path.normalize('/'+path).replace(/^\//, '') if path != ''
    @logger.info 'path after', path
    @logger.info @s3Client
    if s3Bucket?
      @listObjects(path,s3Bucket)
    else
      @listBuckets()



module.exports = Client
