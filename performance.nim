import tree, random, times, os, strutils

template benchmark(benchmarkName: string, code: stmt) =
  let t0 = epochTime()
  code
  let elapsed = epochTime() - t0
  let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
  echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

var
  datom : Datom

let DATOM_COUNT : int = 100000
var t : Treap = createTreap(@[Entity, Value, Attribute])
var datoms : seq[Datom]

benchmark "add datoms":
  for i in 0..DATOM_COUNT - 1:
    var a : int = random(high(int))
    var b : int = random(high(int))
    var c : int = random(high(int))
    var d : Datom = createIntDatom(a, b, c)
    datoms.add(d)
    t.add(d)

benchmark "traverse":
    var iter : TreapIter = t.createTreapIter()
    iter.open()
    while not iter.atEnd:
        iter.open()
        while not iter.atEnd:
            iter.open()
            while not iter.atEnd:
                iter.next()
            iter.up()
            iter.next()
        iter.up()
        iter.next()
    iter.up()