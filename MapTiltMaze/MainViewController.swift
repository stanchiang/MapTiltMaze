//
//  MainViewController.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/12/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate, mapDelegate, overlayDelegate, trailGraphDelegate {

    var map:MapView!
    var overlay:OverlayView!
    var game:GameLevels!
    
    var currentTrailGraph:TrailGraph!
    var currentNode:TrailNode!
    var currentLevel:Int!

    
    let GameModel = [
        [CLLocationCoordinate2D(latitude: 42.5240461369687, longitude: -112.207552427192), CLLocationCoordinate2D(latitude: 42.5001962490471, longitude: -112.166066045599)],
        [CLLocationCoordinate2D(latitude: 43.5240461369687, longitude: -113.207552427192), CLLocationCoordinate2D(latitude: 43.5001962490471, longitude: -113.166066045599)],
        [CLLocationCoordinate2D(latitude: 44.5240461369687, longitude: -114.207552427192), CLLocationCoordinate2D(latitude: 44.5001962490471, longitude: -114.166066045599)],
    ]
//    var prevNode:TrailNode!
//    var userLocation:UserAnnotation!
//    var testLocation:UserAnnotation!
//    var testpolyLine:MKPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load map
        map = MapView(frame: self.view.bounds)
        map.delegate = self
        self.view.addSubview(map)
        
        //add login and main menu
        overlay = OverlayView(frame: CGRectMake(0,self.view.frame.height - 50, self.view.frame.width, 50))
        overlay.delegate = self
        self.view.addSubview(overlay)
        overlay.initGameCenter()
        overlay.loadMainGameMenu()
        
        //init game
        game = GameLevels()
        currentTrailGraph = TrailGraph()
        currentTrailGraph.delegate = self
        currentLevel = 0
        currentNode = nil
        setLevel(level: GameModel.first!)
    }
    
    func setLevel(level level: [CLLocationCoordinate2D]){
        currentTrailGraph.convertArrayOfEndPointsIntoArrayOfCoordinates(level)
        for endpoint in level {
            map.pinLocation(coordinate: endpoint)
        }
    }
    
    func updateLevel(direction: Int) {
        let levelIndex = currentLevel + direction
        if GameModel.isInBounds(levelIndex) {
            map.clearMap()
            setLevel(level: GameModel[levelIndex])
            currentLevel = levelIndex
        } else {
            print("out of bounds")
        }
    }
    
    func play() {
        print("play")
        map.processMotion()
    }
    
    func didGetCoordinates(routeCoordinates: [CLLocationCoordinate2D]) {
        if !game.levels.isInBounds(currentLevel) {
            let trailGraph = TrailGraph()
            game.levels.append(trailGraph)
            game.levels[currentLevel].nodes = game.levels.last!.convertArrayOfCoordinatesIntoArrayOfTrailNodes(routeCoordinates)
        }
        
        currentNode = game.levels[currentLevel].nodes.first!
        print("start point: \(GameModel.first!.first!)")
        print("currentLevel: \(currentLevel)")
        print("currentNode: \(currentNode.location)")
        map.drawRoute(routeCoordinates)
    }
    
    func showGameCenterLogin(sender: UIViewController) {
        self.presentViewController(sender, animated: true) { () -> Void in
            print("presented view controller")
        }
    }
    
    func pinLocation(sender:UILongPressGestureRecognizer){
        if sender.state != .Began {
            return
        }
        
        map.pinLocation(sender: sender)
    
        if map.annotations.count > 1 {
            map.drawRoute()
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.blueColor()
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //        http://stackoverflow.com/questions/25631410/swift-different-images-for-annotation?rq=1
        print("delegate called")
        
        if !(annotation is UserAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! UserAnnotation
        anView!.image = UIImage(named: cpa.imageName)
        anView!.alpha = 0.8
        return anView
    }
    
    func getCurrentUserLocationNode() -> TrailNode {
        return currentNode
    }
    
    func getFirstNodeForGivenLevel() -> TrailNode {
        return currentNode
    }
    
}

extension Array {
    func isInBounds(index: Int) -> Bool {
        if index < 0 || index > self.count - 1 {
            return false
        }
        return true
    }
}