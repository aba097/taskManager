//
//  ViewController.swift
//  tackManage
//
//  Created by 相場智也 on 2022/09/06.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditViewControllerDelegate, AddViewControllerDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pickerView: UIPickerView!
    var selectedPickerCategory = "全カテゴリ"
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        TaskDataModel.CreateInitialCategory()
        TaskDataModel.getTaskData()
        TaskDataModel.getCategoryData()
        TaskDataModel.SearchGetTaskData(text: searchText, categoryName: selectedPickerCategory)
        
        // TableView に長押し検知のためのジェスチャーを初期化
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(displayTaskDetail))
        // ロングタップを検出するまでの時間を指定
        longTap.minimumPressDuration = 0.5
        // 指のずれを許容する
        longTap.allowableMovement = 10
        // TableView にジェスチャーを追加する
        tableView.addGestureRecognizer(longTap)
    }
    

    @objc func displayTaskDetail(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        // 指が離された位置を取得して、その位置の IndexPath を取得する
        let touchPoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            showMessage(selectedtask: TaskDataModel.searchtaskdata[indexPath.row])
        }
    }
    
    func showMessage(selectedtask: TaskData){
        
        var title = selectedtask.title
        if selectedtask.category!.categoryName == "カテゴリを選択" {
            title += "(デフォルト)"
        }else{
            title += "(" + selectedtask.category!.categoryName + ")"
        }
        
        var msg = ""
        if selectedtask.content != nil {
            msg = selectedtask.content!
        }
        if selectedtask.deadline != nil {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ja_JP")
            df.dateFormat = "\nyyyy年MM月dd日 ah時mm分まで"
            msg += df.string(from: selectedtask.deadline!)
        }
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let edit = UIAlertAction(title: "編集", style: .default) { (action) in
            //編集画面へ
            self.transitionEditViewController(selectedtask: selectedtask)
        }
        alert.addAction(edit)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func transitionEditViewController(selectedtask: TaskData){
        //Identifier(result)はStoryboardで指定
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "edit") as! EditViewController
        
        editViewController.delegate = self
        editViewController.initTitleText = selectedtask.title
        if selectedtask.content != nil {
            editViewController.initContentText = selectedtask.content!
        }
        editViewController.initCategoryButtonName = selectedtask.category!.categoryName
        editViewController.initColorButtonColor = UIColor(hex: selectedtask.category!.categoryColor)!
        if selectedtask.deadline != nil {
            editViewController.initDateSwitchIsOn = true
            editViewController.tappedDate = selectedtask.deadline!
        }
        editViewController.targetTaskData = selectedtask
        
        self.present(editViewController, animated: true, completion: nil)
    }

    @IBAction func SearchButtonAction(_ sender: Any) {
        if let word = searchBar.text {
            searchText = word
        }
        
        setSearchTaskData()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let word = searchBar.text {
            searchText = word
        }
        
        setSearchTaskData()
        tableView.reloadData()
    }
    
    func setSearchTaskData(){
        TaskDataModel.SearchGetTaskData(text: searchText, categoryName: selectedPickerCategory)
    }
    
    @IBAction func calendarSwitchAction(_ sender: UISwitch) {
        
        if sender.isOn {
            let calendarViewController = storyboard?.instantiateViewController(withIdentifier: "calendar") as! CalendarViewController
            //フルスクリーンで画面遷移
            calendarViewController.modalPresentationStyle = .fullScreen
            self.present(calendarViewController, animated: true, completion: nil)
            sender.isOn = false
        }
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        //Identifier(result)はStoryboardで指定
        let addViewController = storyboard?.instantiateViewController(withIdentifier: "add") as! AddViewController
        addViewController.delegate = self
        self.present(addViewController, animated: true, completion: nil)
    }
    
    //delegate
    func appendTaskData(title: String, content: String?, deadline: Date?, categoryIndex: Int){
        TaskDataModel.getCategoryData()
        TaskDataModel.save(title: title, content: content, deadline: deadline, index: categoryIndex)
        TaskDataModel.getTaskData()
        tableView.reloadData()
    }
    
    func updateTaskData(taskdata: TaskData, title: String, content: String?, deadline: Date?, categoryIndex: Int){
        TaskDataModel.getCategoryData()
        TaskDataModel.updateTask(taskdata: taskdata, title: title, content: content, deadline: deadline, categoryIndex: categoryIndex)
        TaskDataModel.getTaskData()
        TaskDataModel.SearchGetTaskData(text: searchText, categoryName: selectedPickerCategory)
        tableView.reloadData()
    }

    
    func backViewDoReloadTaskData(){
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskDataModel.searchtaskdata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        cell.titleLabel.text = TaskDataModel.searchtaskdata[indexPath.row].title
        cell.categoryButton.backgroundColor = UIColor(hex: TaskDataModel.searchtaskdata[indexPath.row].category!.categoryColor)
        cell.contentLabel.text = TaskDataModel.searchtaskdata[indexPath.row].content
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath) {
        TaskDataModel.delete(taskdata: TaskDataModel.searchtaskdata[indexPath.row])
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return TaskDataModel.categorydata.count + 1
    }
     
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        var list: [String] = []
        list.append("全カテゴリ")
        for i in 0..<TaskDataModel.categorydata.count {
            if TaskDataModel.categorydata[i].categoryName == "カテゴリを選択" {
                list.append("デフォルト")
            }else{
                list.append(TaskDataModel.categorydata[i].categoryName)
            }
        }
        return list[row]
    }
     
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        var list: [String] = []
        list.append("全カテゴリ")
        for i in 0..<TaskDataModel.categorydata.count {
            list.append(TaskDataModel.categorydata[i].categoryName)
        }
        
        selectedPickerCategory = list[row]
        
    }
}

