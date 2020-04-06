import tablemark from "tablemark"

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

  h3 "Releases"

  table ["Release", "Start", "Finish"],
    ({name, start, finish}) ->
      [ name, (start.format "ll"), (finish.format "ll") ]
    plan.releases

  h3 "Slack"

  table [ "Duration", "People", "Capacity", "Effort", "Slack" ],
    ({duration, people, capacity, effort, slack}) ->
      [
        "#{duration.asDays()} days"
        people
        "#{capacity.asDays()} days"
        "#{effort.asDays()} days"
        "#{slack.asDays()} days"
      ]
    [ plan ]

  ": Weekends and holidays excluded."
]

components = ({plan, process}) -> [

  h3 "Components"

  for component in plan.components

    component.type = "component"

    [

      h4 component.name

      component.description

      tasks component, process

    ]
]

features = ({plan, process}) -> [

  h2 "Features"

  for feature in plan.features

    feature.type = "feature"

    [

      h4 feature.name

      feature.description

      tasks feature, process

    ]
]

tasks = (product, process) ->

  if (product.tasks)?

    [

      join "\n",

        for task in product.tasks
          "- #{task.name} (#{task.effort.humanize()})"

      "Total: #{product.effort.humanize()}"

    ]

render = stitch [
  header
  releases
  components
  features
]

export default render
