fs     = require 'graceful-fs'
path   = require 'path'
rimraf = require 'rimraf'
tmpdir = path.join process.env.TMPDIR, 'node-sprite-temp'

sprite = require '../index.coffee'

# generate directories and place a random number of images in each one
module.exports =
  testMultipleImageDirs: (beforeExit, assert) ->
    numImageDirs = 25
    rimraf tmpdir, (err) ->
      if err then console.log err
      fs.mkdirSync tmpdir
      imagePath = './test/sample-images'
      files = fs.readdirSync imagePath
      images = []
      files.forEach (file) ->
        if not (/\.(png|jpg|gif)/.exec file)
          return
        images.push file
      # data to verify output against
      structure = {}
      for i in [1..numImageDirs]
        dir = structure["multiple-images-#{i}"] = []
        images.sort(-> return 0.5 - Math.random())
        numImages = Math.floor(Math.random() * images.length) + 1
        if numImages is 0 then numImages = 1
        num = 0
        while num < numImages
          dir.push images[num]
          num++
      for key, val of structure
        dirPath = (path.resolve tmpdir, key)
        fs.mkdirSync dirPath
        for image in val
          srcFile = (path.resolve imagePath, image)
          destFile = (path.resolve dirPath, image)
          fs.createReadStream(srcFile).pipe(fs.createWriteStream(destFile))
      sprite.sprites {path: tmpdir}, (err, result) ->
        if err then console.log err
        compiledFiles = fs.readdirSync tmpdir
        spriteFiles = []
        compiledFiles.forEach (file) ->
          if not (/\.png$/.exec file)
            return
          spriteFiles.push file
        # console.log 'sprites:', spriteFiles
        assert.equal spriteFiles.length, numImageDirs
