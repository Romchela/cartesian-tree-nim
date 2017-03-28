import unittest, tree, nimprof

suite "work with tree (entity, value, attribute)":
    setup:
        var r : Treap = createTreap(@[Entity, Value, Attribute])
        var datoms : seq[Datom] = @[]
        datoms.add(createStringDatom(3, 42, "hey"))
        datoms.add(createStringDatom(1, 55, "there"))
        datoms.add(createStringDatom(1, 77, "there"))
        datoms.add(createStringDatom(0, 55, "x"))
        datoms.add(createStringDatom(1, 88, "a"))
        datoms.add(createStringDatom(7, 42, "fuckit"))
        datoms.add(createStringDatom(7, 11, "aargh"))
        for datom in datoms:
            r.add(datom)

    test "tree order":
        var order : seq[Datom] = @[]
        r.getTreap(order)

        var correctOrder : seq[string] = @[
            "(entity: 0, attribute: 55, kind: String, stringValue: x)",
            "(entity: 1, attribute: 88, kind: String, stringValue: a)",
            "(entity: 1, attribute: 55, kind: String, stringValue: there)",
            "(entity: 1, attribute: 77, kind: String, stringValue: there)",
            "(entity: 3, attribute: 42, kind: String, stringValue: hey)",
            "(entity: 7, attribute: 11, kind: String, stringValue: aargh)",
            "(entity: 7, attribute: 42, kind: String, stringValue: fuckit)"
        ]

        check(order.len == correctOrder.len)
        for i in 0..order.len - 1:
            check($order[i] == correctOrder[i])

    test "up and next":
        var iter : TreapIter = r.createTreapIter()
        var log : seq[string] = @[]

        iter.open()
        while not iter.atEnd:
            log.add($key(iter))
            iter.open()
            while not iter.atEnd:
                log.add("- " & $key(iter))
                iter.open()
                while not iter.atEnd:
                    log.add("-- " & $key(iter))
                    iter.next()
                iter.up()
                iter.next()
            iter.up()
            iter.next()
        iter.up()

        var correctLog = @[
            "(entity: 0, attribute: 55, kind: String, stringValue: x)",
            "- (entity: 0, attribute: 55, kind: String, stringValue: x)",
            "-- (entity: 0, attribute: 55, kind: String, stringValue: x)",
            "(entity: 1, attribute: 88, kind: String, stringValue: a)",
            "- (entity: 1, attribute: 88, kind: String, stringValue: a)",
            "-- (entity: 1, attribute: 88, kind: String, stringValue: a)",
            "- (entity: 1, attribute: 55, kind: String, stringValue: there)",
            "-- (entity: 1, attribute: 55, kind: String, stringValue: there)",
            "-- (entity: 1, attribute: 77, kind: String, stringValue: there)",
            "(entity: 3, attribute: 42, kind: String, stringValue: hey)",
            "- (entity: 3, attribute: 42, kind: String, stringValue: hey)",
            "-- (entity: 3, attribute: 42, kind: String, stringValue: hey)",
            "(entity: 7, attribute: 11, kind: String, stringValue: aargh)",
            "- (entity: 7, attribute: 11, kind: String, stringValue: aargh)",
            "-- (entity: 7, attribute: 11, kind: String, stringValue: aargh)",
            "- (entity: 7, attribute: 42, kind: String, stringValue: fuckit)",
            "-- (entity: 7, attribute: 42, kind: String, stringValue: fuckit)"
        ]

        check(correctLog.len == log.len)
        for i in 0..correctLog.len - 1:
            check(correctLog[i] == log[i])

    proc checkOrder(r : Treap) = 
        var order : seq[Datom] = @[]
        r.getTreap(order)
        for i in 1..order.len - 1:
            check(order[i - 1] < order[i])

    test "seek":
        var it : TreapIter
        for i in datoms:
            it = r.seek(i)
            check(not it.atEnd)
            check(key(it) == i)
        it = r.seek(createStringDatom(1, 56, "there"))
        check(key(it) == datoms[2])
        it = r.seek(createStringDatom(-1, 2, "ex"))
        check(key(it) == datoms[3])
        it = r.seek(createStringDatom(10, 3, "test"))
        check(it.atEnd)
        
    test "add & erase":
        r.add(createIntDatom(2, 31, 15))
        r.checkOrder()
        r.erase(createStringDatom(7, 42, "fuckit"))
        r.checkOrder()
        r.erase(createStringDatom(1, 55, "there"))
        r.checkOrder()
        r.erase(createStringDatom(1, 77, "there"))
        r.checkOrder()
        r.add(createStringDatom(1, 77, "there"))
        r.checkOrder()

    test "begin":
        var it : TreapIter = r.begin()
        var order : seq[Datom] = @[]
        r.getTreap(order)
        for i in order:
            check(key(it) <= i)

suite "work with tree (value, entity, attribute)":
    setup:
        var r : Treap = createTreap(@[Value, Entity, Attribute])
        var datoms : seq[Datom] = @[]
        datoms.add(createStringDatom(3, 42, "hey"))
        datoms.add(createStringDatom(1, 55, "there"))
        datoms.add(createStringDatom(1, 77, "there"))
        datoms.add(createStringDatom(0, 55, "x"))
        datoms.add(createStringDatom(1, 88, "a"))
        datoms.add(createStringDatom(7, 42, "fuckit"))
        datoms.add(createStringDatom(7, 11, "aargh"))
        for datom in datoms:
            r.add(datom)

    test "tree order":
        var order : seq[Datom] = @[]
        r.getTreap(order)

        var correctOrder : seq[string] = @[
            "(entity: 1, attribute: 88, kind: String, stringValue: a)",
            "(entity: 7, attribute: 11, kind: String, stringValue: aargh)",
            "(entity: 7, attribute: 42, kind: String, stringValue: fuckit)",
            "(entity: 3, attribute: 42, kind: String, stringValue: hey)",
            "(entity: 1, attribute: 55, kind: String, stringValue: there)",
            "(entity: 1, attribute: 77, kind: String, stringValue: there)",
            "(entity: 0, attribute: 55, kind: String, stringValue: x)"
        ]

        check(order.len == correctOrder.len)
        for i in 0..order.len - 1:
            check($order[i] == correctOrder[i])

suite "datom test":

    test "equals":
        var a, b : Datom
        a = createStringDatom(1, 2, "3")
        b = createIntDatom(1, 2, 3)
        check(a == a)
        check(b == b)
        check(a != b)

        a = createStringDatom(11, 23, "abc")
        b = createStringDatom(11, 23, "abc")
        check(a == b)

        a = createFloatDatom(1, 2, 2.0)
        b = createFloatDatom(1, 2, 2)
        check(a == b)

        a = createFloatDatom(1, 3, 5.0)
        b = createFloatDatom(1, 2, 5)
        check(a != b)

        a = createStringDatom(12, 2, "ds")
        b = createStringDatom(11, 2, "ds")
        check(a != b)

    test "less":
        var a, b : Datom
        a = createStringDatom(1, 2, "3")
        b = createIntDatom(1, 2, 3)
        check(b < a)
        a = createStringDatom(1, 1, "a")
        b = createStringDatom(1, 2, "a")
        check(a < b)
        a = createStringDatom(5, 1, "a")
        b = createStringDatom(4, 2, "a")
        check(b < a)
        a = createStringDatom(1, 1, "a")
        b = createStringDatom(1, 1, "a")
        check(not (a < b))

    