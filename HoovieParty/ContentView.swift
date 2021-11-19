//
//  ContentView.swift
//  HoovieParty
//
//  Created by Gary Host on 11/14/21.
//

// https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers
// https://stackoverflow.com/questions/60582392/swiftui-passing-data-from-swiftuiview-to-scenekit
// https://stackoverflow.com/questions/58258964/how-to-combine-arkit-and-swiftui-without-using-the-storyboard-and-or-iboutlets
// https://www.vadimbulavin.com/using-uikit-uiviewcontroller-and-uiview-in-swiftui/


import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        ZStack(alignment: .bottom) {
            //ARViewContainer()
            MyARSCNView()
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    Text("Hello world")
                }
            }
        }
    }
}


struct MyARSCNView: UIViewRepresentable {
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: MyARSCNView
        
        init(_ parent: MyARSCNView) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            print("session")
            let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
            cubeNode.position = SCNVector3(0, 0, -0.2)
            parent.arView.scene.rootNode.addChildNode(cubeNode)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            print("renderer")
            // This visualization covers only detected planes.
                guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

                // Create a SceneKit plane to visualize the node using its position and extent.
                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                let planeNode = SCNNode(geometry: plane)
                planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)

                // SCNPlanes are vertically oriented in their local coordinate space.
                // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

                // ARKit owns the node corresponding to the anchor, so make the plane a child node.
                node.addChildNode(planeNode)
        }
        
        
        @objc
        func handleTap(sender: UITapGestureRecognizer) {
            let result = self.parent.arView.hitTest(sender.location(in: sender.view), types: ARHitTestResult.ResultType.featurePoint)
            
            guard let firstHit = result.first else {return}
            let hitWorldPosition = firstHit.worldTransform.columns.3
            
            let cubenode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
            cubenode.position = SCNVector3.init(hitWorldPosition.x, hitWorldPosition.y, hitWorldPosition.z)
            
            parent.arView.scene.rootNode.addChildNode(cubenode)
            
            
            
            //let hitPosition = result.first?.worldTransform.columns.3
            //cubenode.position = SCNVector3.init(hitPosition!.x, hitPosition!.y, hitPosition!.z)
            
            //parent.arView.scene.rootNode.addChildNode(cubenode)
            
            
            /*
            
            
            
            print(result)
             */
        }
        
    }
  
    var arView = ARSCNView(frame: .zero)
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        // arView = ARSCNView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        arView.session.run(configuration)
        
        let scene = SCNScene(named: "scene.scn")!
        arView.scene = scene
        
        arView.delegate = context.coordinator
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(sender:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
    
        return arView
    }
    
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
    
}


struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
