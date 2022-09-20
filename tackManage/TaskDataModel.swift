//
//  TaskDataModel.swift
//  tackManage
//
//  Created by 相場智也 on 2022/09/07.
//

import Foundation
import RealmSwift
import UIKit

class TaskData: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var content: String? = ""
    @objc dynamic var deadline: Date? = Date()
    @objc dynamic var category: Category?
}

class Category: Object {
    @objc dynamic var categoryName: String = ""
    @objc dynamic var categoryColor: String = ""
}

class InitialLaunchCheck: Object {
    @objc dynamic var InitialLaunchFlag: Bool = true
}

class TaskDataModel {
    
    static var taskdata: Results<TaskData>!
    static var searchtaskdata: Results<TaskData>!
    static var categorydata: Results<Category>!
    
    static func save(title: String, content: String?, deadline: Date?, index: Int){
        let onetaskdata  = TaskData()
        onetaskdata.title = title
        onetaskdata.content = content
        onetaskdata.deadline = deadline
        onetaskdata.category = categorydata[index]
        
        let realm = try! Realm()

        try! realm.write {
          realm.add(onetaskdata)
        }
    }
    
    static func delete(taskdata: TaskData){
        
        let realm = try! Realm()
        // データ削除
        try! realm.write {
            realm.delete(taskdata)
        }
    }
    
    static func SearchGetTaskData(text: String, categoryName: String){
        let realm = try! Realm()
        // 全データ検索
        if categoryName == "全カテゴリ" && text == "" {
            let results = realm.objects(TaskData.self)
            searchtaskdata = results
            return
        }
        if categoryName == "全カテゴリ" && text != "" {
            let results = realm.objects(TaskData.self).filter("title CONTAINS %@",text)
            searchtaskdata = results
            return
        }
        if categoryName != "全カテゴリ" && text == "" {
            let results = realm.objects(TaskData.self).filter("category.categoryName == %@",categoryName)
            searchtaskdata = results
            return
        }
        
        let results = realm.objects(TaskData.self).filter("title CONTAINS %@ && category.categoryName == %@", text, categoryName)
        searchtaskdata = results
 
    }
    
    static func CreateInitialCategory(){
        let realm = try! Realm()
        
        let results = realm.objects(InitialLaunchCheck.self)
        
        if results.count != 0 {
            return
        }
        
        //初回起動時
        //initialflagを入れる
        let initialflag  = InitialLaunchCheck()
        initialflag.InitialLaunchFlag = false

        try! realm.write {
          realm.add(initialflag)
        }
        
        //初期cateogryを作成する
        TaskDataModel.createCategory(name: "カテゴリを選択", color: UIColor.gray.toHexString())
        TaskDataModel.createCategory(name: "学校", color: UIColor.green.toHexString())
        TaskDataModel.createCategory(name: "就活", color: UIColor.yellow.toHexString())
        
    }
    
    static func createCategory(name: String, color: String){
        let realm = try! Realm()
        
        let newcateogry = Category()
        newcateogry.categoryName = name
        newcateogry.categoryColor = color
        try! realm.write {
          realm.add(newcateogry)
        }
    }
    
    static func updateCategory(index: Int, name: String, color: String){
        let realm = try! Realm()
        
        try! realm.write {
            categorydata[index].categoryName = name
            categorydata[index].categoryColor = color
        }
    }
    
    static func updateTask(taskdata: TaskData, title: String, content: String?, deadline: Date?, categoryIndex: Int){
        let realm = try! Realm()
        try! realm.write {
            taskdata.title = title
            taskdata.content = content
            taskdata.deadline = deadline
            taskdata.category = categorydata[categoryIndex]
        }
    }

    
    static func getCategoryData(){
        let realm = try! Realm()

        // 全データ検索
        let results = realm.objects(Category.self)
        categorydata = results
    }
    
    static func getTaskData(){
        let realm = try! Realm()

        // 全データ検索
        let results = realm.objects(TaskData.self)
        taskdata = results
    }
}


//realmはUIColorを保存できないので16進(String)に変換して保存する
//let color1: UIColor = UIColor(hex: "79a3b1")
//let hexColor1: String = color1.toHexString(
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func toHexString() -> String {
        var red: CGFloat     = 1.0
        var green: CGFloat   = 1.0
        var blue: CGFloat    = 1.0
        var alpha: CGFloat   = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(String(Int(floor(red*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let g = Int(String(Int(floor(green*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let b = Int(String(Int(floor(blue*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let a = Int(String(Int(floor(alpha*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!

        let result = String(r, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(g, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(b, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(a, radix: 16).leftPadding(toLength: 2, withPad: "0")
        return result
    }
}

extension String {
    // 左から文字埋めする
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}
