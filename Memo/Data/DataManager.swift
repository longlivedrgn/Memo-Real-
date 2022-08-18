//
//  DataManager.swift
//  Memo
//
//  Created by 김용재 on 2022/08/18.
//

import Foundation
import CoreData


class DataManager {
    
    static let shared = DataManager()
    
    private init() {
        // Singleton 싱글톤
    }
    
    var mainContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    // 메모를 데이터베이스에서 읽어오는 코드를 작성해보자
    var memoList = [Memo]()
    
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        // 날짜를 내림차순으로 정렬해보자.
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        // 최종결과가 memoList에 저장이된다. 
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    // 새로운 메모를 데이터 베이스에 저장하기
    func addNewMemo(_ memo: String?){
        // DataManager의 Memo이다.
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        // 현재 날자를 그대로 저장하기
        newMemo.insertDate = Date()
        
        // memoList에 바로 넣어주기
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Memo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}