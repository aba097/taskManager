//
//  CategoryViewController.swift
//  tackManage
//
//  Created by 相場智也 on 2022/09/08.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CategoryTableViewCellDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    var selectedCategoryIndex = 0
    var parentView = "edit"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        TaskDataModel.getCategoryData()
        TaskDataModel.getTaskData()


    }
    
    
    @IBAction func decisionButtonAction(_ sender: Any) {
        
        let indexPath = IndexPath(row:selectedCategoryIndex , section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        
        let color = cell.colorButoon.backgroundColor!
        let categoryName = cell.textField.text!
        
        //新しいカテゴリの場合は追加する
        if selectedCategoryIndex == TaskDataModel.categorydata.count {
            TaskDataModel.createCategory(name: categoryName, color: color.toHexString())
        }
        
        //カテゴリ名や色が変化している可能性があるため、現在のものに更新する
        for i in 0..<TaskDataModel.categorydata.count {
            let updateindexPath = IndexPath(row:i , section: 0)
            let updatecell = tableView.cellForRow(at: updateindexPath) as! CategoryTableViewCell
            let updatecolor = updatecell.colorButoon.backgroundColor!
            let updatecategoryName = updatecell.textField.text!
            TaskDataModel.updateCategory(index: i, name: updatecategoryName, color: updatecolor.toHexString())
        }
        
        if parentView == "edit" {
            let vc = self.presentingViewController as! EditViewController
            vc.backViewDoSetCategory(categoryNmae: categoryName, color: color, selectedCategoryIndex: selectedCategoryIndex)
            self.dismiss(animated: true, completion: nil)
        }else if parentView == "add" {
            let vc = self.presentingViewController as! AddViewController
            vc.backViewDoSetCategory(categoryNmae: categoryName, color: color, selectedCategoryIndex: selectedCategoryIndex)
            self.dismiss(animated: true, completion: nil)
        }
        

    }
    
    @IBAction func returnButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //delegate categorytableviewcellからcolor pickerを閉じたときに呼ばれる
    //色をcellのbuttonにセットする
    func selectedColor(color: UIColor, index: Int) {
        let indexPath = IndexPath(row:index , section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        cell.colorButoon.backgroundColor = color
    }
    
    //cell tap event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        selectedCategoryIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskDataModel.categorydata.count + 1
    }
    
    //tableviewの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categorycell") as? CategoryTableViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        //最後に新規登録できるようなセルを用意する
        if indexPath.row == TaskDataModel.categorydata.count {
            cell.colorButoon.backgroundColor = .brown
            cell.colorPicker.selectedColor = .brown
            cell.delegate = self
            cell.colorButoon.tag = indexPath.row
            cell.textField.text = "新しいカテゴリ"
            return cell
        }
        
        cell.colorButoon.backgroundColor = UIColor(hex: TaskDataModel.categorydata[indexPath.row].categoryColor)
        cell.colorPicker.selectedColor = UIColor(hex: TaskDataModel.categorydata[indexPath.row].categoryColor)!
        cell.delegate = self
        cell.colorButoon.tag = indexPath.row
        cell.textField.text = TaskDataModel.categorydata[indexPath.row].categoryName
        
        //カテゴリを選択するのところtextFieldは編集負荷でタッチ負荷(tableviewcellに記載)
        if indexPath.row == 0 {
            cell.textField.isEnabled = false
        }
        
        return cell
    }

    

}

//親のViewControllerを取得する
extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
}
