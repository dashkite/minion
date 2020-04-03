import {spawn} from "child_process"
import {join, resolve, relative} from "path"

# TODO I don't really understand why this needs a require
p9k = require "panda-9000"

import {rmr} from "panda-quill"
import {go, map, wait, tee, reject} from "panda-river"
import coffee from "coffeescript"

{define, run, glob, read, write,
  extension, copy, watch} = p9k

# TODO we really need a solid shell abstraction for quill
shell = (command, path = ".") ->
  child = spawn command,
    shell: true
    cwd: resolve process.cwd(), path
    stdio: "inherit"

local = (path) ->
  require.resolve path, paths: [ process.cwd() ]

compile = tee ({source, target}) ->
  target.content = coffee.compile source.content,
    bare: true
    inlineMap: true
    filename: join "..", relative ".", source.path
    transpile:
      presets: [[
        local "@babel/preset-env"
        targets: node: "current"
      ]]

define "build", [ "clean", "js&", "bin&" ]

define "clean", -> rmr "build"

define "js", ->
  go [
    glob [ "**/*.coffee" ], "./src"
    wait map read
    compile
    map extension ".js"
    map write "./build/src"
  ]

define "bin", ->
  go [
    glob [ "bin/*" ], "./src"
    map copy "./build/src"
  ]


define "test:js", ->
  go [
    glob [ "**/*.coffee" ], "./test"
    wait map read
    compile
    map extension ".js"
    map write "./build/test"
  ]

define "test:run", ->
  shell "node --enable-source-maps build/test/index.js"

define "test", [ "build", "test:js", "test:run" ]
