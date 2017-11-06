//
//  Part1VC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import JWGCircleCounter

class Part2VC: UIViewController {
    
    @IBOutlet weak var circleTime: JWGCircleCounter!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var recordingMess: UILabelX!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tv_Data: UITextView!
    @IBOutlet weak var img_Photo: UIImageViewX!
    @IBOutlet weak var decreaseBtn: UIButtonX!
    @IBOutlet weak var increaseBtn: UIButtonX!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var controlTextView: UIView!
    @IBOutlet weak var controlImageView: UIView!
    
    var expectTime:TimeInterval = timeCoutdown
    var Exam:NSDictionary?
    var audio1_Data: Data?
    var audio2_Data: Data?
    
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    let userID = userDefault.object(forKey: USERID_STRING) as? Int
    var examID:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioRecorderManager.shared.recorder?.prepareToRecord()
        circleTime.circleBackgroundColor = .clear
        circleTime.circleColor = .white
        circleTime.circleTimerWidth = 2
        circleTime.delegate = self
        recordingMess.isHidden = true
        nextBtn.isHidden = true
        
        img_Photo.isHidden = true
        tv_Data.isHidden = true
        
        if Exam?["question_2"] as? String == nil
        {
            lbl_Title.text = TITLEPHOTO
            img_Photo.isHidden = false
            controlTextView.isHidden = true
            controlImageView.isHidden = false
            img_Photo.contentMode = .scaleAspectFit
            img_Photo.sd_setIndicatorStyle(.white)
            img_Photo.sd_showActivityIndicatorView()
            img_Photo.sd_setShowActivityIndicatorView(true)
            img_Photo.sd_setImage(with: URL(string: Exam?["image_2"] as! String), placeholderImage: nil, options: [.continueInBackground]) { (iamge, error, type, url) in
                
                self.circleTime.start(withSeconds: timeInitial)
            }            
        }
        else
        {
            lbl_Title.text = TITLESTRING
            controlTextView.isHidden = false
            controlImageView.isHidden = true
            tv_Data.isHidden = false
            tv_Data.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 10)
            tv_Data.text = Exam?["question_2"] as! String
            circleTime.start(withSeconds: timeInitial)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tv_Data.isScrollEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tv_Data.isScrollEnabled = true
        
    }
    
    @IBAction func decreaseSizeTap(_ sender: Any) {
        
        tv_Data.decreaseFontSize()
    }
    
    @IBAction func increaseSizeTap(_ sender: Any) {
        
        tv_Data.increaseFontSize()
    }
    
    @IBAction func onClickPromt(_ sender: Any) {
        
        if Exam?["image_2"] as? String != nil
        {
            let promt_1 = Exam?["promt2_1"] as? String
            let promt_2 = Exam?["promt2_2"] as? String
            let promt_3 = Exam?["promt2_3"] as? String
            self.alert_PromtQuestion(title: "Question", mess: promt_1! + promt_2! + promt_3! )

        }
    }
    
    
    @IBAction func nextBtnTap(_ sender: Any) {
        
        if Exam?["question_3"] as? String == nil && Exam?["image_3"] as? String == nil
        {
            let endVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "endassessmentVC") as! EndVC
            self.navigationController?.pushViewController(endVC, animated: true)
        }
        else
        {
            let part3_tempVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "part3_tempVC") as! Part3VC
            
            part3_tempVC.Exam = self.Exam
            part3_tempVC.examID = self.examID
            part3_tempVC.audio1_Data = self.audio1_Data
            part3_tempVC.audio2_Data = self.audio2_Data
            
            self.navigationController?.pushViewController(part3_tempVC, animated: true)
        }
    }
    
}

extension Part2VC: JWGCircleCounterDelegate
{
    func circleCounterTimeDidExpire(_ circleCounter: JWGCircleCounter!) {
        
        var audioURL:NSURL?
        self.StarRecording(userID: userID!, examID: examID, audio: 2) { (audioURLs:NSURL?) in
            audioURL = audioURLs
        }
        
        self.recordingMess.isHidden = false
        UIView.animate(withDuration: expectTime, animations: {
            self.viewBackground.frame.size.width = self.containerView.frame.size.width
            self.view.layoutIfNeeded()
        }, completion: { (done) in
            self.recordingMess.text = "Time Out"
            self.stopRecord()
            do
            {
                self.audio2_Data = try? Data(contentsOf: audioURL! as URL)
                if self.Exam?["question_3"] as? String == nil && self.Exam?["image_3"] as? String == nil
                {
                    self.loadingShowwithStatus(status: "Uploading your Exam.")
                    ExamRecord.uploadExam(withToken: self.token!, idExam: self.examID, audiofile1: self.audio1_Data, audiofile2: self.audio2_Data, audiofile3: nil, audiofile4: nil, completion: { (status:Bool?, result:NSDictionary?) in
                        if status!
                        {
                            DispatchQueue.main.async(execute: {
                                self.loadingHide()
                                self.nextBtn.isHidden = false
                            })
                        }
                        
                    })
                }
                else
                {
                    self.nextBtn.isHidden = false
                }                
            }
        })
        
    }
}











