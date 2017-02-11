//
//  LayoutDecisionNode.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/4/14.
//
//

import Foundation

class LayoutDecisionNode
{
    let description:String?
    //let input:AnyObject?
    var edges:[LayoutDecisionEdge] = []
    var cardLayout:WCCardLayout
    
    init(description:String){
        self.description = description
        self.cardLayout = WCCardLayout.unknown
    }
    
    init(description:String, layout:WCCardLayout){
        self.description = description
        self.cardLayout = layout
    }
    
    func addEdge(_ edge: LayoutDecisionEdge, destination:LayoutDecisionNode){
        edge.pre = self
        edge.post = destination
        edges.append(edge)
    }
    
    func numEdges()->Int{
        return edges.count
    }

    func isLeaf()->Bool{
        return edges.count == 0
    }
    
    // Determine which edge to follow, if nothing evalutes return nil (addEdge order matters)
    func edgeToFollow(_ input:AnyObject)->LayoutDecisionEdge?{
        for edge in edges{
            if edge.evaluation(input) == true{
                return edge
            }
        }
        return nil
    }
    
}
