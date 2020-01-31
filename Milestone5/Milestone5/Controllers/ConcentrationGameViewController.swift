//
//  ConcentrationGameViewController.swift
//  Milestone5
//
//  Created by Lareen Melo on 1/28/20.
//  Copyright © 2020 Lareen Melo. All rights reserved.
//

import UIKit

class ConcentrationGameViewController: UICollectionViewController {
    
    @IBOutlet var cardBackImage: UIImageView!
    var cards =  [Card]()
    let pairs = 3
    var cardsFacingUp = [CardCollectionViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let game = Concentration()
        cards = game.shuffle(pairs)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as? CardCollectionViewCell else { fatalError("Could not dequeue cell") }
        
        let card = cards[indexPath.row]
        cell.configure(card)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else { return }
        
        if cell.card.state == false {
            cell.flip()
            cardsFacingUp.append(cell)
            
            if cardsFacingUp.count == 2 {
                if cardsFacingUp[0].emoji.text != cardsFacingUp[1].emoji.text {
                    for card in cardsFacingUp {
                        card.flipBack()
                    }
                } else {
                    // FIXME: disable simultaneously
                    cardsFacingUp[0].disable()
                    cardsFacingUp[1].disable()
                }
                
                cardsFacingUp = [CardCollectionViewCell]()
            }
        }
    }
}

extension ConcentrationGameViewController: UICollectionViewDelegateFlowLayout {
    // FIXME: Refactor me pls
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionSize = collectionView.frame.size
        let numberOfColumns = CGFloat(pairs)
        let numberOfRows = CGFloat(2.0)
        guard let navigationItemHeight = navigationController?.navigationBar.frame.height else { return CGSize(width: 0.0, height: 0.0) }
        
        
        guard let statusBar = view.window?.windowScene?.statusBarManager?.statusBarFrame.size.height else { return CGSize(width: 0.0, height: 0.0) }
        
        let width = collectionSize.width / numberOfColumns
        let height = (collectionSize.height - (navigationItemHeight + statusBar)) / numberOfRows
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}