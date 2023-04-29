//
//  ATCCenteredListView.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/13/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCCenteredListView: UIViewRepresentable {
    var data: [String]
    
    func makeCoordinator() -> ATCCenteredListView.Coordinator {
        Coordinator(data: data)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        var passThroughData: [String]

        init(data: [String]) {
            self.passThroughData = data
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            passThroughData.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredCollectionViewCell", for: indexPath) as! ATCCenteredCollectionViewCell
            cell.imageName = passThroughData[indexPath.row]
            return cell
        }
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = ATCCenteredCollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(ATCCenteredCollectionViewCell.self, forCellWithReuseIdentifier: "CenteredCollectionViewCell")
        collectionView.backgroundColor = UIColor(hexString: "#f4f6fa")
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {}
}
