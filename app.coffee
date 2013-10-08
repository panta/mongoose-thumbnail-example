express = require('express')
path = require('path')

mongoose = require('mongoose')

db = mongoose.connect('mongodb://localhost/mongoose-thumbnail-example')
mongooseThumbnailLib = require('mongoose-thumbnail')
mongooseThumbnailPlugin = mongooseThumbnailLib.thumbnailPlugin

# ---------------------------------------------------------------------
#   mongoose models
# ---------------------------------------------------------------------

uploads_base = path.join(__dirname, "uploads")

PictureSchema = new mongoose.Schema({
  title: String
})
PictureSchema.plugin(mongooseThumbnailPlugin, {
  name: "photo"
  inline: false
  upload_to: path.join(uploads_base, "u")
  relative_to: uploads_base
})

Picture = db.model("Picture", PictureSchema)

# ---------------------------------------------------------------------
#   express app
# ---------------------------------------------------------------------

app = express()

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(app.router)
app.use(express.logger('dev'))

app.use('/', express.static(path.join(__dirname, 'public')))
app.use('/uploads', express.static(uploads_base))

app.get '/', (req, res, next) ->
  Picture.find (err, pictures) ->
    return next(err) if err
    res.render('index', { pictures: pictures })

app.post '/upload', (req, res, next) ->
  console.log(req.body)
  picture = new Picture({ title: req.body.title })
  picture.set('photo.file', req.files.photo)
  picture.save (err) ->
    return next(err) if err
  res.redirect('/')

app.listen(3000)
console.log("listening on port 3000 in #{app.settings.env} mode")
