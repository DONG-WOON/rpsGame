//
//  MyInformationView.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/16.
//

import UIKit

class MyInformationView: UIView {

    @IBOutlet weak var myProfiileImage: UIImageView!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var myGameRecord: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("MyInformationView",
                                            owner: self,
                                            options: nil)?.first as? UIView
        
        guard let view = view else { return }
//        view.backgroundColor = UIColor(displayP3Red: 148/255, green: 180/255, blue: 159/255, alpha: 1)
        view.backgroundColor = UIColor(red: 148/255, green: 180/255, blue: 159/255, alpha: 1)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.frame = self.bounds
        addSubview(view)
        myProfiileImage.contentMode = .scaleAspectFill
    }
}
