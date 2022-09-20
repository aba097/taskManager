//
//  EditViewController.swift
//  tackManage
//
//  Created by 相場智也 on 2022/09/09.
//

import UIKit

protocol EditViewControllerDelegate {
    func updateTaskData(taskdata: TaskData, title: String, content: String?, deadline: Date?, categoryIndex: Int)
}

class EditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var colorButton: UIButton!
    
    @IBOutlet weak var dateSwitch: UISwitch!
    
    var delegate: EditViewControllerDelegate?
    var tappedDate: Date? = nil
    
    var selectedCategoryIndex = 0
    
    var initTitleText = ""
    var initContentText = ""
    var initCategoryButtonName = "カテゴリを選択"
    var initColorButtonColor = UIColor.gray
    var initDateSwitchIsOn = false
    
    var targetTaskData: TaskData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        titleTextField.text = initTitleText
        contentTextView.text = initContentText
        categoryButton.setTitle(initCategoryButtonName, for: .normal)
        colorButton.backgroundColor = initColorButtonColor
        
        //TODO: ごりおしコード、initColorButtonCOlorをindexで渡すようにするなどする
        for i in 0..<TaskDataModel.categorydata.count {
            if TaskDataModel.categorydata[i].categoryColor == initColorButtonColor.toHexString() {
                selectedCategoryIndex = i
            }
        }
        if initDateSwitchIsOn {
            dateSwitch.isOn = true
            datePicker.isHidden = false
        }else{
            dateSwitch.isOn = false
            datePicker.isHidden = true
        }
        
        TaskDataModel.getCategoryData()
        //colorButton.backgroundColor = UIColor(hex: TaskDataModel.categorydata[selectedCategoryIndex].categoryColor)
        //categoryButton.setTitle(TaskDataModel.categorydata[selectedCategoryIndex].categoryName, for: .normal)
        
        if tappedDate != nil {
            datePicker.date = tappedDate!
        }
        
        //textViewのレイアウト
        contentTextView.layer.borderColor = UIColor.gray.cgColor.copy(alpha: 0.2)
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 5.0
        contentTextView.layer.masksToBounds = true
        
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action:    #selector(doneButtonTaped))
       doneToolbar.items = [spacer, doneButton]
       contentTextView.inputAccessoryView = doneToolbar
        
        //TextField, TextView以外をタップしたときにキーボードを閉じる
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    @objc
    func doneButtonTaped(sender: UIButton) {
        contentTextView.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }
    
    
    @IBAction func dateSwitchAction(_ sender: UISwitch) {
        if dateSwitch.isOn && datePicker.isHidden{
            datePicker.isHidden = false
        }
        else if !dateSwitch.isOn && !datePicker.isHidden {
            datePicker.isHidden = true
        }
    }
    
    //カテゴリ選択ボタンアクションs
    @IBAction func categoryButtonAction(_ sender: Any) {
        //Identifier(result)はStoryboardで指定
        let categoryViewController = storyboard?.instantiateViewController(withIdentifier: "category") as! CategoryViewController
        categoryViewController.parentView = "edit"
        self.present(categoryViewController, animated: true, completion: nil)
    }
    
    func backViewDoSetCategory(categoryNmae: String, color: UIColor, selectedCategoryIndex: Int){
        colorButton.backgroundColor = color
        categoryButton.setTitle(categoryNmae, for: .normal)
        self.selectedCategoryIndex = selectedCategoryIndex
    }
    
    @IBAction func returnButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateButtonAction(_ sender: Any) {
        
        if titleTextField.text! != ""{
            
            var deadline: Date? = nil
            if dateSwitch.isOn {
                deadline = datePicker.date
            }
            
            var contentText: String? = nil
            if contentTextView.text != nil {
                contentText = contentTextView.text!
            }
       
            self.delegate?.updateTaskData(taskdata: targetTaskData! ,title: titleTextField.text!, content: contentText, deadline: deadline, categoryIndex: selectedCategoryIndex)
            
            
            let alert = UIAlertController(title: "更新しました", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "Error", message: "入力されていません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
}
