import random, typetraits

type
    DatomField* = enum
        Entity,
        Value,
        Attribute

    ValueType* = enum
        Int,
        String,
        Float

    Datom* = object
        entity : int
        attribute : int
        case kind : ValueType
        of Int:
        intValue : int
        of String:
        stringValue : string
        of Float:
        floatValue : float

    Treap* = ref TreapObj

    TreapObj* = object
        root : ref Node
        order : seq[DatomField]

    Node* = object
        datom : Datom
        priority : int
        left : ref Node
        right : ref Node

    TreapIter* = object
        node : ref Node
        depth : int
        atEnd : bool

var treap : Treap
var typeOrder : seq[ValueType] = @[Int, Float, String]

proc getTypeId(t : ValueType) : int =
    var id : int = 0
    for x in typeOrder:
        if t == x:
            return id
        inc(id)

proc `<`(a : Datom, b : Datom): bool =
    for field in treap.order:
        if field == Value:
            if a.kind == b.kind:
                if a.kind == Int:
                    if a.intValue != b.intValue:
                        return a.intValue < b.intValue
                elif a.kind == Float:
                    if a.floatValue != b.floatValue:
                        return a.floatValue < b.floatValue
                elif a.kind == String:
                    if a.stringValue != b.stringValue:
                        return a.stringValue < b.stringValue
            else:
                var idA = getTypeId(a.kind)
                var idB = getTypeId(b.kind)
                return idA < idB
        elif field == Entity:
            if a.entity != b.entity:
                return a.entity < b.entity
        elif field == Attribute:
            if a.attribute != b.attribute:
                return a.attribute < b.attribute
    return false

proc `==`(a : Datom, b : Datom): bool =
    if a.kind != b.kind:
        return false
    if a.kind == Int and a.intValue != b.intValue:
        return false
    if a.kind == String and a.stringValue != b.stringValue:
        return false
    if a.kind == Float and a.floatValue != b.floatValue:
        return false
    return a.entity == b.entity and a.attribute == b.attribute


proc split(node : ref Node, key : Datom, leftTree : var ref Node, rightTree : var ref Node) =
    if node == nil:
        leftTree = nil
        rightTree = nil
    elif key < node.datom:
        split(node.left, key, leftTree, node.left)
        rightTree = node
    else:
        split(node.right, key, node.right, rightTree)
        leftTree = node

proc setDatomFields(entity : int, attribute : int, datom : var Datom) =
    datom.entity = entity
    datom.attribute = attribute

proc createEmptyDatom() : Datom =
    var datom : Datom
    datom.kind = String
    setDatomFields(-1, -1, datom)
    datom.stringValue = "end iterator"
    return datom

proc createIntDatom*(entity : int, attribute : int, value : int) : Datom =
    var datom : Datom
    datom.kind = Int
    setDatomFields(entity, attribute, datom)
    datom.intValue = value
    return datom

proc createStringDatom*(entity : int, attribute : int, value : string) : Datom =
    var datom : Datom
    datom.kind = String
    setDatomFields(entity, attribute, datom)
    datom.stringValue = value
    return datom

proc createFloatDatom*(entity : int, attribute : int, value : float) : Datom =
    var datom : Datom
    datom.kind = Float
    setDatomFields(entity, attribute, datom)
    datom.floatValue = value
    return datom

proc createNode(datom : Datom) : ref Node =
    var node : ref Node = new(Node)
    node.datom = datom
    node.priority = random(high(int))
    node.left = nil
    node.right = nil
    return node

proc add(node : var ref Node, addNode : ref Node) =
    if node == nil:
        node = addNode
    elif addNode[].priority > node[].priority:
        split(node, addNode.datom, addNode.left, addNode.right)
        node = addNode
    else:
        if addNode.datom < node.datom:
            add(node.left, addNode)
        else:
            add(node.right, addNode)

proc add*(t : var Treap, datom : Datom) =
    add(t.root, createNode(datom))

proc merge(node : var ref Node, leftTree : ref Node, rightTree : ref Node) =
    if leftTree == nil:
        node = rightTree
    elif rightTree == nil:
        node = leftTree
    elif leftTree.priority > rightTree.priority:
        merge(leftTree.right, leftTree.right, rightTree)
        node = leftTree
    else:
        merge(rightTree.left, leftTree, rightTree.left)
        node = rightTree

proc erase(node : var ref Node, key : Datom) =
    if node.datom == key:
        merge(node, node.left, node.right)
    else:
        if key < node.datom:
            erase(node.left, key)
        else:
            erase(node.right, key)

proc erase*(t : Treap, key : Datom) =
    erase(t.root, key)

proc seek(node : ref Node, key : Datom): ref Node =
    if node == nil:
        return nil
    elif node.datom == key:
        return node
    elif node.datom < key:
        return seek(node.right, key)
    else:
        var leftNode = seek(node.left, key)
        if leftNode == nil:
            return node
        else:
            return leftNode

proc seek*(t : Treap, key : Datom): TreapIter =
    var node : ref Node = seek(t.root, key)
    var it : TreapIter
    if node == nil:
        it.atEnd = true
    else:
        it.atEnd = false
        it.node = node
    return it

proc upperbound(node : ref Node, key : Datom): ref Node =
    if node == nil:
        return nil
    elif node.datom == key or node.datom < key:
        return upperbound(node.right, key)
    else:
        var leftNode = upperbound(node.left, key)
        if leftNode == nil:
            return node
        else:
            return leftNode

proc print(node : var ref Node) =
    if node != nil:
        if node.left != nil:
            print(node.left)
        echo node.datom
        if node.right != nil:
            print(node.right)

proc print*(t : var Treap) =
    print(t.root)

proc atEnd*(it : var TreapIter): bool =
    return it.atEnd

proc next*(it : var TreapIter) =
    var nextNode = upperbound(treap.root, it.node.datom)
    if (nextNode == nil):
        it.atEnd = true
    else:
        var currentDepth : int = 0
        var isGood : bool = true
        for t in treap.order:
            if currentDepth > it.depth:
                break
            if t == Value:
                if it.node.datom.kind == String:
                    if nextNode.datom.stringValue != it.node.datom.stringValue:
                        isGood = false
                        break
                elif it.node.datom.kind == Float:
                    if nextNode.datom.floatValue != it.node.datom.floatValue:
                        isGood = false
                        break
                elif it.node.datom.kind == Int:
                    if nextNode.datom.intValue != it.node.datom.intValue:
                        isGood = false
                        break
            elif t == Attribute:
                if nextNode.datom.attribute != it.node.datom.attribute:
                    isGood = false
                    break
            elif t == Entity:
                if nextNode.datom.entity != it.node.datom.entity:
                    isGood = false
                    break
            inc(currentDepth)
        if not isGood:
            it.atEnd = true
        else:
            it.atEnd = false
            it.node = nextNode

proc begin*(root : ref Node): TreapIter =
    var it : TreapIter
    var node : ref Node = root
    if node == nil:
        it.node = nil
        it.atEnd = true
        return it
    while node.left != nil:
        node = node.left
    it.node = node
    it.atEnd = false
    return it

proc open*(it : var TreapIter) =
    inc(it.depth)

proc up*(it : var TreapIter) =
    dec(it.depth)
    it.atEnd = false

proc key*(it : TreapIter): Datom =
    if it.atEnd:
        return createEmptyDatom()
    return it.node.datom

proc getTreap(node : ref Node, result : var seq[Datom]) =
    if node != nil:
        if node.left != nil:
            getTreap(node.left, result)
        result.add(node.datom)
        if node.right != nil:
            getTreap(node.right, result)

iterator preorder*(root : ref Node): Datom =
    var nodes : seq[Datom]
    nodes = @[]
    getTreap(root, nodes)
    for i in nodes:
        yield(i)

proc createTreap*(order : seq[DatomField]): Treap =
    var root : ref Node
    root = nil
    new(treap)
    treap.root = root
    treap.order = order
    return treap

proc createTreapIter*(t : Treap): TreapIter =
    var it : TreapIter
    it.depth = -2
    it.atEnd = false
    it.node = begin(t.root).node
    return it