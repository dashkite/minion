import tablemark from "tablemark"
import {titleCase} from "panda-parchment"

identity = (x) -> x

join = (d, sx) -> sx.join d

map = (f, ax) -> ax.map f

reduce = (k, f, ax) -> ax.reduce f, k

cat = (ax, bx) -> ax.concat bx

push = (ax, a) -> ax.push a ; ax

isArray = (ax) -> Array.isArray ax

flatten = do ({f} = {}) ->
  f = (bx, a) -> if (isArray a) then (cat bx, flatten a) else (push bx, a) ; bx
  (ax) -> reduce [], f, ax

compact = (ax) -> a for a in ax when a?

stitch = (fx) ->
  (project) -> join "\n\n", compact flatten (f project for f in fx)

h1 = (heading) -> "# #{heading}"
h2 = (heading) -> "## #{heading}"
h3 = (heading) -> "### #{heading}"
h4 = (heading) -> "#### #{heading}"
h5 = (heading) -> "##### #{heading}"

table = (headings, transform, rows) ->
  tablemark (map transform, rows),
    columns: headings

header = ({plan}) -> h2 "Project: #{plan.name}"

releases = ({plan}) -> [

  h2 "Releases"

  for {name, start, finish} in plan.releases
    [
      h4 name
      "Start: #{start.format "ll"}. Finish: #{finish.format "ll"}"
    ]
]

work = ({plan: {duration, effort, people, capacity, slack}}) -> [

  h2 "Work Effort"

  """
  The project duration is #{duration.asDays()} works days
  (weekends and holidays excluded).
  The project requires #{effort.asDays()} work to complete.
  We have #{people} full-time equivalent people assigned,
  representing a capacity of #{capacity.asDays()} work days,
  allowing for #{slack.asDays()} days of slack.
  """
]

approach = ({workflows}) -> [

  h2 "Workflows"

  for type, flows of workflows
    [
      h2 titleCase type
      flows.description

      for name, flow of flows.roles
        [
          h4 titleCase name
          """
          #{flow.description}
          Tasks: #{join ', ', (task.name for task in flow.tasks)}.
          """
        ]
    ]
]

products = ({plan}) -> [

  for type in [ "features", "components" ]
    [
      h2 titleCase type

      for {name, description, effort} in plan[ type ]
        [
          # intentionally skipping a heading level
          h4 name
          "#{description[..-2]} (#{effort.humanize()})."
        ]
    ]
]




render = stitch [
  # header
  releases
  work
  approach
  products
]

export default render
