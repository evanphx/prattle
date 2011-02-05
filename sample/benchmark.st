Blah define ; add: x to: y ; as: [
  x + y
].

self import: 'benchmark'.
res := Benchmark ~measure: [
  self print: 'in measure'.
  10000000 ~times: [ :i |
    Blah new add: 8 to: 4
  ]
].
Kernel ~puts: res
