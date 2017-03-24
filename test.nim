import tree

var
  datom1 : Datom
  datom2 : Datom
  datom3 : Datom
  datom4 : Datom
  datom5 : Datom
  datom6 : Datom


datom1 = createStringDatom(3, 2, "abs")
datom2 = createIntDatom(1, 2, 23)
datom3 = createIntDatom(1, 2, 12)
datom4 = createStringDatom(1, 3, "sds")
datom5 = createFloatDatom(2, 4, 2.3)

var treap : Treap = createTreap(@[Entity, Attribute, Value])

treap.add(datom1);
treap.add(datom2);
treap.add(datom3);
treap.add(datom4);
treap.add(datom5);


treap.print()
echo "--------"

var it : TreapIter = treap.createTreapIter()

it.open()
echo key(it)
it.next()
echo key(it)
it.next()
echo key(it)
it.next()
echo key(it)
echo "======="
it = treap.createTreapIter()
it.open()
it.open()
echo key(it)
it.next()
echo key(it)
it.next()
echo key(it)
it.up()
it.next()
echo key(it)


echo "!!!!!!!!!!!!!!!!!!!"

var r : Treap = createTreap(@[Entity, Value, Attribute])
r.add(createStringDatom(3, 42, "hey"))
r.add(createStringDatom(1, 55, "there"))
r.add(createStringDatom(1, 77, "there"))
r.add(createStringDatom(0, 55, "x"))
r.add(createStringDatom(1, 88, "a"))
r.add(createStringDatom(7, 42, "fuckit"))
r.add(createStringDatom(7, 11, "aargh"))

r.print()
echo "--------"

var iter : TreapIter = r.createTreapIter()

iter.open()
while not iter.atEnd:
  echo key(iter)
  #
  iter.open()
  while not iter.atEnd:
    echo " - ", key(iter)
    #
    iter.open()
    while not iter.atEnd:
      echo " -- ", key(iter)
      #
      #
      iter.next()
    iter.up()
    #
    iter.next()
  iter.up()
  iter.next()
iter.up()