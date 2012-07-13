LoadPackage("io");

Read("misc.gap");
Read("coxeter.gap");
Read("twistedinvolutionweakordering-persist.gap");

TwistedInvolutionDeduceNodeAndEdgeFromGraph := function(matrix, startNode, startLabel, labels)
    local rank, comb, trace, possibleEqualNodes, e, k, n;
    
    rank := -1/2 + Sqrt(1/4 + 2*Length(matrix)) + 1;
    possibleEqualNodes := [];
    
    for comb in List(Filtered(labels, label -> label <> startLabel), label -> rec(startNode := startNode, s := [startLabel, label], m := CoxeterMatrixEntry(matrix, rank, startLabel, label))) do
        trace := [];
        k := 1;
        n := comb.startNode;
        
        Add(trace, rec(node := n, edge := rec(label := comb.s[1], type := -1)));
        
        while k < comb.m do
            e := FindElement(n.inEdges, e -> e.label = comb.s[k mod 2 + 1]);
            if e = fail then break; fi;
            n := e.source;

            Add(trace, rec(node := n, edge := e));
            k := k + 1;
        od;
        
        while k > 0 do
            e := FindElement(n.outEdges, e -> e.label = comb.s[k mod 2 + 1]);
            if e = fail then break; fi;
            n := e.target;
            
            Add(trace, rec(node := n, edge := e));
            k := k - 1;
        od;
        
        if k <> 0 then continue; fi;
        
        if Length(trace) = 2*comb.m then
            return rec(result := 0, node := trace[Length(trace)].node, type := trace[comb.m + 1].edge.type, trace := trace);
        fi;
        
        if Length(trace) >= 4 then
            if trace[Length(trace) / 2 + 1].edge.type <> trace[Length(trace) / 2].edge.type then
                # cannot be equal
            else
                if trace[Length(trace)].edge.type = 0 then
                    return rec(result := 0, node := trace[Length(trace)].node, type := 0, trace := trace);
                else
                    Add(possibleEqualNodes, trace[Length(trace)].node);
                fi;
            fi;
        else
            Add(possibleEqualNodes, trace[Length(trace)].node);
        fi;
    od;

    return rec(result := -1, possibleEqualNodes := possibleEqualNodes);
end;

# Calculates the poset Wk(theta).
TwistedInvolutionWeakOrdering := function (filename, W, matrix, theta)
    local persistInfo, maxOrder, nodes, edges, absNodeIndex, absEdgeIndex, prevNode, currNode, newEdge,
        label, type, deduction, startTime, endTime, S, k, i, s, x, y, n;
    
    persistInfo := TwistedInvolutionWeakOrderingPersistResultsInit(filename);
    
    S := GeneratorsOfGroup(W);
    maxOrder := Minimum([Maximum(Concatenation(matrix, [1])), 5]);
    nodes := [ [], [ rec(element := One(W), twistedLength := 0, inEdges := [], outEdges := [], absIndex := 1) ] ];
    edges := [ [], [] ];
    absNodeIndex := 2;
    absEdgeIndex := 1;
    k := 0;

    while Length(nodes[2]) > 0 do
        if not IsFinite(W) then
            if k > 200 or absNodeIndex > 10000 then
                break;
            fi;
        fi;
        
        for i in [1..Length(nodes[2])] do
            Print(k, " ", i, "         \r");
            
            prevNode := nodes[2][i];
            for label in Filtered([1..Length(S)], n -> Position(List(prevNode.inEdges, e -> e.label), n) = fail) do
                deduction := TwistedInvolutionDeduceNodeAndEdgeFromGraph(matrix, prevNode, label, [1..Length(S)]);
                
                if deduction.result = 0 then
                    type := deduction.type;
                    currNode := deduction.node;
                elif deduction.result = 1 then
                    type := deduction.type;
                    
                    currNode := rec(element := y, twistedLength := k + 1, inEdges := [], outEdges := [], absIndex := absNodeIndex);
                    Add(nodes[1], currNode);
                    
                    absNodeIndex := absNodeIndex + 1;
                else
                    x := prevNode.element;
                    s := S[label];
                    
                    type := 1;
                    y := s^theta*x*s;
                    if (CoxeterElementsCompare(x, y)) then
                        y := x * s;
                        type := 0;
                    fi;

                    currNode := FindElement(deduction.possibleEqualNodes, n -> CoxeterElementsCompare(n.element, y));

                    if currNode = fail then
                        currNode := rec(element := y, twistedLength := k + 1, inEdges := [], outEdges := [], absIndex := absNodeIndex);
                        Add(nodes[1], currNode);
                        
                        absNodeIndex := absNodeIndex + 1;
                    fi;
                fi;
                
                newEdge := rec(source := prevNode, target := currNode, label := label, type := type, absIndex := absEdgeIndex);

                Add(edges[1], newEdge);
                Add(currNode.inEdges, newEdge);
                Add(prevNode.outEdges, newEdge);
                
                absEdgeIndex := absEdgeIndex + 1;
            od;
        od;
        
        TwistedInvolutionWeakOrderingPersistResults(persistInfo, nodes[2], edges[2]);

        Add(nodes, [], 1);
        Add(edges, [], 1);
        if (Length(nodes) > maxOrder + 1) then
            for n in nodes[maxOrder + 2] do
                n.inEdges := [];
                n.outEdges := [];
            od;
            Remove(nodes, maxOrder + 2);
            Remove(edges, maxOrder + 2);
        fi;
        k := k + 1;
    od;
    
    TwistedInvolutionWeakOrderingPersistResultsInfo(persistInfo, W, matrix, theta, absNodeIndex - 1, k - 1);
    TwistedInvolutionWeakOrderingPersistResultsClose(persistInfo);
    
    return rec(numNodes := absNodeIndex - 1, numEdges := absEdgeIndex - 1, maxTwistedLength := k - 1);
end;

# Calculates the poset Wk(theta).
TwistedInvolutionWeakOrdering1 := function (filename, W, matrix, theta)
    local persistInfo, maxOrder, nodes, edges, absNodeIndex, absEdgeIndex, prevNode, currNode, newEdge,
        label, type, deduction, startTime, endTime, S, k, i, s, x, y, n;
    
    persistInfo := TwistedInvolutionWeakOrderingPersistResultsInit(filename);
    
    S := GeneratorsOfGroup(W);
    maxOrder := Minimum([Maximum(Concatenation(matrix, [1])), 5]);
    nodes := [ [], [ rec(element := One(W), twistedLength := 0, inEdges := [], outEdges := [], absIndex := 1) ] ];
    edges := [ [], [] ];
    absNodeIndex := 2;
    absEdgeIndex := 1;
    k := 0;

    while Length(nodes[2]) > 0 do
        if not IsFinite(W) then
            if k > 200 or absNodeIndex > 10000 then
                break;
            fi;
        fi;
        
        for i in [1..Length(nodes[2])] do
            Print(k, " ", i, "         \r");
            
            prevNode := nodes[2][i];
            for label in Filtered([1..Length(S)], n -> Position(List(prevNode.inEdges, e -> e.label), n) = fail) do
                x := prevNode.element;
                s := S[label];
                
                type := 1;
                y := s^theta*x*s;
                if (CoxeterElementsCompare(x, y)) then
                    y := x * s;
                    type := 0;
                fi;

                currNode := FindElement(nodes[1], n -> CoxeterElementsCompare(n.element, y));

                if currNode = fail then
                    currNode := rec(element := y, twistedLength := k + 1, inEdges := [], outEdges := [], absIndex := absNodeIndex);
                    Add(nodes[1], currNode);
                    
                    absNodeIndex := absNodeIndex + 1;
                fi;
                
                newEdge := rec(source := prevNode, target := currNode, label := label, type := type, absIndex := absEdgeIndex);

                Add(edges[1], newEdge);
                Add(currNode.inEdges, newEdge);
                Add(prevNode.outEdges, newEdge);
                
                absEdgeIndex := absEdgeIndex + 1;
            od;
        od;
        
        TwistedInvolutionWeakOrderingPersistResults(persistInfo, nodes[2], edges[2]);

        Add(nodes, [], 1);
        Add(edges, [], 1);
        if (Length(nodes) > maxOrder + 1) then
            for n in nodes[maxOrder + 2] do
                n.inEdges := [];
                n.outEdges := [];
            od;
            Remove(nodes, maxOrder + 2);
            Remove(edges, maxOrder + 2);
        fi;
        k := k + 1;
    od;
    
    TwistedInvolutionWeakOrderingPersistResultsInfo(persistInfo, W, matrix, theta, absNodeIndex - 1, k - 1);
    TwistedInvolutionWeakOrderingPersistResultsClose(persistInfo);
    
    return rec(numNodes := absNodeIndex - 1, numEdges := absEdgeIndex - 1, maxTwistedLength := k - 1);
end;

TwistedInvolutionWeakOrderungResiduum := function (vertex, labels)
    local visited, queue, residuum, current, edge;
    
    visited := [ vertex ];
    queue := [ vertex ];
    residuum := [];
    
    while Length(queue) > 0 do
        current := queue[1];
        Remove(queue, 1);
        Add(residuum, current);
        
        for edge in current.outEdges do
            if edge.label in labels and not edge.target in visited then
                Add(visited, edge.target);
                Add(queue, edge.target);
            fi;
        od;
    od;

    return residuum;
end;

TwistedInvolutionWeakOrderungLongestWord := function (vertex, labels)
    local current;
    
    current := vertex;
    
    while Length(Filtered(current.outEdges, e -> e.label in labels)) > 0 do
        current := Filtered(current.outEdges, e -> e.label in labels)[1].target;
    od;
    
    return current;
end;

