const express = require('express')
const path = require('path')
const app = express()
const port = 8080

app.get('/isalive', (req, res) => res.sendStatus(200))
app.get('/isready', (req, res) => res.sendStatus(200))

app.use(express.static(path.resolve(__dirname, 'dist')))

app.listen(port, () => console.log(`App listening on port ${port}!`))