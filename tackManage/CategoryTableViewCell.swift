//
//  CategoryTableViewCell.swift
//  tackManage
//
//  Created by 相場智也 on 2022/09/08.
//

import UIKit

protocol CategoryTableViewCellDelegate {
    func selectedColor(color: UIColor, index: Int)
}

class CategoryTableViewCell: UITableViewCell, UIColorPickerViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var colorButoon: UIButton!
    
    var colorPicker = UIColorPickerViewController()
    var delegate: CategoryTableViewCellDelegate?
    var selectedButtonId = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorPicker.delegate = self
        textField.delegate = self        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }

    @IBAction func colorButtonAction(_ sender: UIButton) {
        colorPicker.supportsAlpha = true
        selectedButtonId = sender.tag
        
        //選択しないのボタンはクリック不可
        if selectedButtonId == 0 {
            return
        }
        
        let parentVC = self.parentViewController() as! CategoryViewController
        parentVC.present(colorPicker, animated: true)
    }
    
    //色を選択したときに呼ばれる
//    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
//        selectedColor = viewController.selectedColor
//    }

    //カラーピッカーを閉じたときに呼ばれる
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
//        print(selectedColor)
//        print(type(of: selectedColor)) //UICGColor
        self.delegate?.selectedColor(color: viewController.selectedColor, index: selectedButtonId)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
