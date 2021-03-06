//
//  MenuViewController.swift
//  Navty
//
//  Created by Thinley Dorjee on 3/1/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import SnapKit
import PubNub

class MenuViewController: UIViewController, UISplitViewControllerDelegate, PNObjectEventListener {

    var client: PubNub!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorPalette.darkBlue
        navigationController?.isNavigationBarHidden = true
        
        viewHierarchy()
        constrainConfiguration()
        
        let configuration = PNConfiguration(publishKey: "pub-c-28163faf-5853-487e-8cc9-1d8f955ad129", subscribeKey: "sub-c-0ee17ac4-08cb-11e7-b95c-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
        print("willdisappear")
        
       
    }
 
    func viewHierarchy(){
        view.addSubview(profilePicture)
        view.addSubview(contactButton)
        view.addSubview(contactLineView)
        view.addSubview(trackingButton)
        view.addSubview(trackingLineView)
        view.addSubview(switchLabel)
        view.addSubview(trackingSwitch)
        view.addSubview(panicButton)
        view.addSubview(panicLineView)
        view.addSubview(copyrightLabel)
    }
    
    func constrainConfiguration(){
        self.edgesForExtendedLayout = []
        
        profilePicture.snp.makeConstraints { (photo) in
            photo.height.width.equalTo(100)
            photo.top.equalTo(view.snp.top).offset(75)
            photo.centerX.equalTo(view.snp.centerX)
        }
        
        contactButton.snp.makeConstraints { (button) in
            button.height.equalTo(49)
            button.width.equalToSuperview().multipliedBy(0.9)
            button.top.equalTo(profilePicture.snp.bottom).offset(45)
            button.trailing.equalToSuperview()
        }
        
        contactLineView.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.9)
            view.top.equalTo(contactButton.snp.bottom)
            view.height.equalTo(1)
        }


        trackingButton.snp.makeConstraints { (button) in
            button.height.equalTo(49)
            button.width.equalToSuperview().multipliedBy(0.9)
            button.top.equalTo(contactLineView.snp.bottom)
            button.trailing.equalToSuperview()
        }
        
        trackingLineView.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.9)
            view.top.equalTo(trackingButton.snp.bottom)
            view.height.equalTo(1)
        }
        
        panicButton.snp.makeConstraints { (button) in
            button.top.equalTo(trackingLineView.snp.bottom).offset(1)
            button.height.equalTo(49)
            button.width.equalToSuperview().multipliedBy(0.9)
            button.trailing.equalToSuperview()
        }
        
        panicLineView.snp.makeConstraints({ (view) in
            view.trailing.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.9)
            view.top.equalTo(panicButton.snp.bottom)
            view.height.equalTo(1)
        })
        
        switchLabel.snp.makeConstraints({ (view) in
            view.leading.equalToSuperview().inset(20)
            view.bottom.equalTo(copyrightLabel.snp.top).inset(-10)
        })
        
        trackingSwitch.snp.makeConstraints({ (view) in
            view.bottom.equalTo(copyrightLabel.snp.top).inset(-15)
            view.trailing.equalToSuperview().inset(20)
            view.height.equalTo(switchLabel.snp.height)
        })
        
        copyrightLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(5)
            view.leading.trailing.equalToSuperview()
        }
    }
    
    func contactsController() {
        dismiss(animated: true, completion: nil)
        let ContactsTC = ContactsTableViewController()
        if let navVC = self.navigationController {
            navVC.pushViewController(ContactsTC, animated: true)
        }
    }
    
    
    func callButton(_ sender: UIButton) {
        guard let number = URL(string: "telprompt://911") else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        print("calling")
    }
    
    func trackingController() {
        dismiss(animated: true, completion: nil)
        let trackingVC = TrackingViewController()
        if let navVC = self.navigationController {
            navVC.pushViewController(trackingVC, animated: true)
        }
    }
    
    func switchValueChanged(sender: UISwitch) {
        if sender.isOn == true {
            sender.tintColor = ColorPalette.bgColor
            sender.onTintColor = ColorPalette.red
            print("its on")
            
            
            
            //MARK: Initial View

            
               animateBorderColor(view: profilePicture, fromColor: ColorPalette.bgColor.cgColor, toColor: ColorPalette.red.cgColor, duration: 0.5)
            
            switchLabel.text = "T R A C K I N G   O N"
            switchLabel.font = .systemFont(ofSize: 11, weight: UIFontWeightLight)
            Settings.shared.trackingEnabled = true
            
            if Settings.shared.navigationStarted == true {
                let alert = UIAlertController(title: "Channel Name", message: "Enter Channel:", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Channel Here"
                })
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    Settings.shared.channelName = (textField?.text)!
                    print(Settings.shared.channelName)
                    self.client.subscribeToChannels([Settings.shared.channelName], withPresence: true)
                }))
                self.navigationController?.present(alert, animated: true, completion: nil)
            }
        } else {
            print("its off")
            
            //MARK: Initial looks

            
              animateBorderColor(view: profilePicture, fromColor: ColorPalette.red.cgColor, toColor: ColorPalette.bgColor.cgColor, duration: 0.5)
            

            
            switchLabel.text = "T R A C K I N G   O F F"
            switchLabel.font = .systemFont(ofSize: 11, weight: UIFontWeightLight)
            Settings.shared.trackingEnabled = false
        }
    }
    
    func animateBorderColor(view: UIImageView, fromColor: CGColor, toColor: CGColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = fromColor
        animation.toValue = toColor
        animation.duration = duration
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.layer.add(animation, forKey: "color")
        view.layer.borderColor = toColor
    }
    
    
    internal var profilePicture: UIImageView = {
        let photo = UIImageView()
        photo.image = UIImage(named: "PointSevenNavtyIcon")
        photo.layer.cornerRadius = 25
        photo.layer.borderWidth = 2
        photo.layer.masksToBounds = true
        photo.contentMode = .scaleAspectFit
        return photo
    }()

    
    
    internal var contactButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("C O N T A C T", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: UIFontWeightLight)
        button.contentHorizontalAlignment = .left
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(contactsController), for: .touchUpInside)
        return button
    }()
    
    internal lazy var contactLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.24)
        return view
    }()
    
    
    internal var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Profile", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        return button
    }()
    
    internal var panicButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("C A L L  P O L I C E", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: UIFontWeightLight)
        button.contentHorizontalAlignment = .left
        button.alpha = 0.8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(callButton(_:)), for: .touchUpInside)
        return button
    }()
    
    internal lazy var panicLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.24)
        return view
    }()
   
    internal var trackingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("T R A C K I N G", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: UIFontWeightLight)
        button.layer.masksToBounds = true
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(trackingController), for: .touchUpInside)
        return button
    }()
    
    internal lazy var trackingLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.24)
        return view
    }()
    
    internal var switchLabel: UILabel = {
        let label = UILabel()
        label.text = "T R A C K I N G   O F F"
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: UIFontWeightLight)
        return label
    }()
    
    internal var trackingSwitch: UISwitch = {
        let trackingSwitch = UISwitch()
        trackingSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        return trackingSwitch
    }()
    
    internal var copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "Navty © 2017"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 8, weight: UIFontWeightLight)
        return label
    }()
}
