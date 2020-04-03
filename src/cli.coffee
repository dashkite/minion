import YAML from "js-yaml"
import {read} from "panda-quill"

import generate from "../src"

do ->
  try
    [ _plan, _process ] = process.argv[2..]
    console.log generate
      plan: YAML.safeLoad await read _plan
      process: YAML.safeLoad await read _process
  catch error
    console.error error
