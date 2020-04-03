import {DateTime} from "luxon"
import render from "./template"

generate = ({plan, process}) ->

  start = plan.start = DateTime.fromFormat plan.start, "DD"
  finish = undefined
  for release in plan.releases
    release.start = start
    finish = release.finish = start.plus release.duration
    start = finish.plus day: 1
  plan.finish = finish

  render {plan, process}



export default generate
