gulp 	= require 'gulp'
coffee 	= require 'gulp-coffee'
compass	= require 'gulp-compass'
plumber = require 'gulp-plumber'
notify	= require 'gulp-notify'
srcmap 	= require 'gulp-sourcemaps'
connect = require 'gulp-connect'


# compass
compassConf = 
	css: 'css'
	sass: 'scss'

# plumber
plumberArgs =
	errorHandler: notify.onError 'Error: <%= error.message %>'


# task
gulp.task 'coffee', ->
	gulp.src 'coffee/*.coffee'
		.pipe plumber plumberArgs
		#.pipe srcmap.init()
		.pipe coffee({bare: true})
		#.pipe srcmap.write()
		.pipe gulp.dest 'js'

gulp.task 'compass', ->
	gulp.src 'scss/style.scss'
		.pipe plumber plumberArgs
		.pipe compass compassConf
		.pipe gulp.dest 'css'

gulp.task 'connect', ->
	connect.server
		root: ''
		livereload: true


# gulp.task 'browser-sync', ->
# 	browserSync
# 		server:
# 			baserDir: './'

# gulp.task 'browser-reload', ->
# 	browserSync.reload()

gulp.task 'default', ['connect'], ->
	gulp.watch 'coffee/*.coffee', ['coffee']
	gulp.watch 'scss/*.scss', ['compass']
