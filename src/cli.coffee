import YAML from "js-yaml"
import {read} from "panda-quill"

import generate from "../src"

do ->
  try
    [ _plan, _workflows ] = process.argv[2..]
    console.log generate
      plan: YAML.safeLoad await read _plan
      workflows: YAML.safeLoad await read _workflows
  catch error
    console.error error
