//
//  ARInfoView.swift
//  ARApp
//
//  Created by Armando Falanga on 18/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import UIKit

class ARInfoView : UIView {
    var lblDescription = UILabel(frame: CGRect.zero)
    var imgDocument = UIImageView(frame: CGRect.zero)
    var lblTitle = UILabel(frame: CGRect.zero)
    var lblSubTitle = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.9)
    }
    
    convenience init(width: CGFloat, height: CGFloat, title: String, subTitle: String,description: String, image: Data?){
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let img : UIImage? = image != nil ?UIImage(data: image!) : nil;
        controllersInit(title: title, subTitle: subTitle,description: description, image: img)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func controllersInit(title: String, subTitle: String, description: String, image: UIImage?) {
        let stdHeight = self.frame.height
        let stdWidth = self.frame.width
        let fontColor = UIColor(red: 0, green: 122.0/255, blue: 1, alpha: 1)
        
        self.layer.cornerRadius = stdHeight * 0.01
        self.layer.borderColor = UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 0.9).cgColor
        self.layer.borderWidth = 1.0
        
        lblTitle.font = .systemFont(ofSize: stdHeight * 0.073)
        let titleHeight : CGFloat = lblTitle.font.pointSize + lblTitle.font.pointSize * 0.2
        let titleWidth : CGFloat = stdWidth
        let titleX : CGFloat = 0
        let titleY : CGFloat = 0
        lblTitle.text = title
        lblTitle.textColor = fontColor
        lblTitle.textAlignment = .center
        lblTitle.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
        lblTitle.backgroundColor = UIColor(white: 1, alpha: 0)
        self.addSubview(lblTitle)
        
        lblSubTitle.font = .systemFont(ofSize: stdHeight * 0.03)
        let subHeight : CGFloat = lblSubTitle.font.pointSize + lblSubTitle.font.pointSize * 0.1
        let subWidth : CGFloat = stdWidth
        let subX : CGFloat = 0
        let subY : CGFloat = titleHeight
        lblSubTitle.textColor = fontColor
        lblSubTitle.text = subTitle
        lblSubTitle.textAlignment = .center
        lblSubTitle.frame = CGRect(x: subX, y: subY, width: subWidth, height: subHeight)
        lblSubTitle.backgroundColor = UIColor(white: 1, alpha: 0)
        self.addSubview(lblSubTitle)
        
        let imgHeight : CGFloat = image != nil ? stdHeight - titleHeight - subHeight - stdWidth * 0.01 : 0;
        let imgWidth : CGFloat = imgHeight
        let imgX : CGFloat = stdWidth * 0.01
        let imgY : CGFloat = titleHeight + subHeight
        imgDocument.frame = CGRect(x: imgX, y: imgY, width: imgWidth, height: imgHeight)
        imgDocument.image = image
        imgDocument.backgroundColor = .clear
        imgDocument.isHidden = false
        imgDocument.layer.cornerRadius = 5
        imgDocument.contentMode = .scaleAspectFit
        self.addSubview(imgDocument)
        
        
        let lblWidth : CGFloat = stdWidth - imgWidth - stdWidth * 0.03
        let lblHeight : CGFloat = imgHeight
        let lblX = imgWidth + stdWidth * 0.02
        let lblY = imgY
        lblDescription.frame = CGRect(x: lblX, y: lblY, width: lblWidth, height: lblHeight)
        lblDescription.text = description
        lblDescription.isHidden = false
        lblDescription.textAlignment = .left
        lblDescription.numberOfLines = 0
        lblDescription.font = .systemFont(ofSize: stdHeight * 0.04)
        lblDescription.sizeToFit()
        self.addSubview(lblDescription)
    }
    
    func getUIImage() ->  UIImage{
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
