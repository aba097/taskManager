//
//  CalendarViewController.swift
//  tackManage
//
//  Created by 相場智也 on 2022/09/07.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, AddViewControllerDelegate, EditViewControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    var tappedTaskData: [TaskData] = []
    var tappedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        TaskDataModel.getTaskData()
        TaskDataModel.getCategoryData()
        getTodayTask(date: Date())
      
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
            showMessage(selectedtask: tappedTaskData[indexPath.row])
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
    

    @IBAction func calendarSwitchAction(_ sender: UISwitch) {
        if !sender.isOn {
            let vc = self.presentingViewController as! ViewController
            vc.backViewDoReloadTaskData()
            self.dismiss(animated: true, completion: nil)
            sender.isOn = true
        }
    }
    
    //追加するボタンの処理
    @IBAction func addButtonAction(_ sender: Any) {
        //Identifier(result)はStoryboardで指定
        let addViewController = storyboard?.instantiateViewController(withIdentifier: "add") as! AddViewController
        addViewController.delegate = self
        addViewController.tappedDate = tappedDate
        self.present(addViewController, animated: true, completion: nil)
    }
    
    func appendTaskData(title: String, content: String?, deadline: Date?, categoryIndex: Int){
        TaskDataModel.getCategoryData()
        TaskDataModel.save(title: title, content: content, deadline: deadline, index: categoryIndex)
        TaskDataModel.getTaskData()
        getTappedDayTask(date: tappedDate)
        tableView.reloadData()
        //タスクのデッドラインに点をつける
        calendar.reloadData()
    }
    
    func updateTaskData(taskdata: TaskData, title: String, content: String?, deadline: Date?, categoryIndex: Int){
        TaskDataModel.getCategoryData()
        TaskDataModel.updateTask(taskdata: taskdata, title: title, content: content, deadline: deadline, categoryIndex: categoryIndex)
        TaskDataModel.getTaskData()
        tableView.reloadData()
        //タスクのデッドラインに点をつける
        calendar.reloadData()
    }
    
    //カレンダー作成時に呼ばれ、タスクのデッドラインに点をつける
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        var hasEvent: Bool = false
        
        for i in 0..<TaskDataModel.taskdata.count {
            if TaskDataModel.taskdata[i].deadline != nil && df.string(from: TaskDataModel.taskdata[i].deadline!) == df.string(from: date) {
                hasEvent = true
            }
        }
        
        if hasEvent {
            return 1
        }else{
            return 0
        }
    }
    
    //カレンダーをタップしたとき
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        tappedDate = date
        getTappedDayTask(date: date)
        tableView.reloadData()
    }
    
    func getTodayTask(date: Date){
        getTappedDayTask(date: date)
    }
    //tappedTaskDataにタップされた日に存在するタスクを表示する
    func getTappedDayTask(date: Date){
        tappedTaskData = []
        TaskDataModel.getTaskData()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        for i in 0..<TaskDataModel.taskdata.count {
            if TaskDataModel.taskdata[i].deadline != nil && df.string(from: TaskDataModel.taskdata[i].deadline!) == df.string(from: date) {
                tappedTaskData.append(TaskDataModel.taskdata[i])
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tappedTaskData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarcell") as? TableViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        cell.categoryButton.backgroundColor = UIColor(hex: tappedTaskData[indexPath.row].category!.categoryColor)
        cell.titleLabel.text = tappedTaskData[indexPath.row].title
        cell.contentLabel.text = tappedTaskData[indexPath.row].content
        return cell
    }
    
    
    //以下は全てカレンダーの祝日色つけ設定
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)

        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)

        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()

        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }

    //曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }

    //reloadDataで呼ばれる
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        //カレンダーの数値をタスクの色にする(同じ日に複数種類のタスクがある場合は、どれかの色)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
                
        for i in 0..<TaskDataModel.taskdata.count {
            if TaskDataModel.taskdata[i].deadline != nil && df.string(from: TaskDataModel.taskdata[i].deadline!) == df.string(from: date) {
                return UIColor(hex: TaskDataModel.taskdata[i].category!.categoryColor)
            }
        }
        
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }

        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }

        return nil
    }


}
