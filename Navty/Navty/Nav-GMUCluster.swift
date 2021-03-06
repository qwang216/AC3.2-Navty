//
//  Nav-GMUCluster.swift
//  Navty
//
//  Created by Kadell on 3/18/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation


extension NavigationMapViewController: GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    func clustering() {
        var image: [UIImage] = []
        for _ in 0...4 {
            image.append(#imageLiteral(resourceName: "Cluster Image"))
        }
        _ = UIImage(named: "Cluster Image")
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [5,10,50,100,200,500], backgroundImages:[#imageLiteral(resourceName: "Cluster Image"), #imageLiteral(resourceName: "Cluster Image"), #imageLiteral(resourceName: "Cluster Image"), #imageLiteral(resourceName: "Cluster Image"), #imageLiteral(resourceName: "Cluster Image"), #imageLiteral(resourceName: "Cluster Image")])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator as GMUClusterIconGenerator)
        renderer.delegate = self
        
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        getData()
        clusterManager.cluster()
        clusterManager.setDelegate(self, mapDelegate: self)
        
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        
        //marker.icon = UIImage(named: "Cluster Image")
        
        if let crimeData = marker.userData as? ClusterCrimeData {
            //            marker.icon = UIImage(named: "Map Pin-20")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            let d = TimeInterval(1477972800)
            
            let cDate = crimeData.crime.crimeDate
            let sDate = dateFormatter.date(from: cDate)
            
            if let interval = sDate?.timeIntervalSince1970, interval >= d {
                marker.icon = UIImage(named: "red-dot")
            } else {
                marker.icon = UIImage(named: "blue-dot")
                
            }
            
            marker.title = "\(crimeData.crime.description)"
            marker.snippet = "\(crimeData.crime.boro): \(crimeData.crime.area)"
            
        }
        
    }
    
    
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if true {
            let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
            let update = GMSCameraUpdate.setCamera(newCamera)
            mapView.moveCamera(update)
            
        }
        
        return false
    }
}
