import moment from "moment-business-days"
import render from "./template"

tee = (f) -> (ax...) -> f ax... ; ax[0]
pipe = ([f, gx...]) ->
  if gx.length > 0
    g = pipe gx
    (ax...) -> g f ax...
  else f

scale = (duration, factor) ->
  days = moment
  .duration duration.asMilliseconds() * factor
  .asDays()
  moment.duration days: Math.floor days

factors =
  low: 1
  medium: 2
  high: 4

compute =

  dates: ({plan, workflows}) ->
    current = moment plan.start, "ll"
    plan.start = current.clone()
    for release in plan.releases
      release.start = current.clone()
      current.add release.duration
      release.finish = current.clone()
      current.add days: 1
    plan.finish = current.clone()

  effort: ({plan, workflows}) ->
    plan.effort = moment.duration 0
    for type in [ "components", "features" ]
      for product in plan[ type ]
        if (workflow = workflows[ type ][ product.workflow ])?
          product.effort = moment.duration 0
          product.tasks = []
          for {name, effort} in workflow.tasks
            task = {name}
            task.effort = scale (moment.duration effort),
              factors[ product.cost ]
            product.effort.add task.effort
            product.tasks.push task
        plan.effort.add product.effort
    plan.duration = moment.duration days: plan.finish.businessDiff plan.start
    plan.capacity = scale plan.duration, plan.people
    plan.slack = plan.capacity.clone().subtract plan.effort

generate = pipe [
  tee compute.dates
  tee compute.effort
  render
  # ->
]

export default generate
