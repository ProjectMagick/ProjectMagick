//
//  CoreDataStack.swift
//  ProjectMagick
//
//  Created by Kishan on 7/21/20.
//  Copyright © 2020 Kishan. All rights reserved.
//

import UIKit
import CoreData

public class CoreDataStack {
        
    
    // MARK: - Convenience Init
    public convenience init(modelName model: String) {
        self.init()
        modelName = model
        CoreDataUIColorTransformer.register()
        CoreDataURLTransformer.register()
    }
    
    
    public enum MathOperations {
        
        case sum(String)
        case count(String)
        case min(String)
        case max(String)
        case average(String)
        case length(String)
        case abs(String)
        case addto(from: String, to: String)
        case subtractFrom(from: String, to: String)
        case multiplyBy(from: String, to: String)
        case divideBy(from: String, to: String)
        case modulusBy(from: String, to: String)
        
        
        var functionName : String {
            switch self {
            case .addto:
                return "add:to:"
            case .subtractFrom:
                return "from:subtract:"
            case .multiplyBy:
                return "multiply:by:"
            case .divideBy:
                return "divide:by:"
            case .modulusBy:
                return "modulus:by:"
            case .sum:
                return "sum:"
            case .count:
                return "count:"
            case .min:
                return "min:"
            case .max:
                return "max:"
            case .average:
                return "average:"
            case .length:
                return "length:"
            case .abs:
                return "abs:"
            }
        }
    }
    
    
    // MARK: - Properties
    public static let shared = CoreDataStack()
    private var modelName: String = AppInfo.appName ?? ""
        
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var backgroundMOC: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    
    public func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


//MARK:- To Create Fetch Request
public extension CoreDataStack {
    
    static func FetchRequestForController<M>(_ type : M.Type, sortUsing : [(key : KeyPath<M,String>, ascending : Bool)], batchCount : Int = 0) -> NSFetchRequest<M> where M : NSManagedObject {
        let request = NSFetchRequest<M>(entityName: String(describing: type))
        request.fetchBatchSize = batchCount
        let sortDescriptors = sortUsing.map { NSSortDescriptor(keyPath: $0.0, ascending: $0.1) }
        request.sortDescriptors = sortDescriptors
        return request
    }
    
}


//MARK:- To do things in Batch
public extension CoreDataStack {
    
    @discardableResult
    func batchUpdateWithCount<M>(_ type : M.Type, propertiesToUpdate : Dictionary<String, Any>) -> Int? where M : NSManagedObject {
        
        let batchUpdate = NSBatchUpdateRequest(entityName: String(describing: type))
        batchUpdate.resultType = .updatedObjectsCountResultType
        batchUpdate.affectedStores = context.persistentStoreCoordinator?.persistentStores
        batchUpdate.propertiesToUpdate = propertiesToUpdate
        do {
            let batchResult = try context.execute(batchUpdate) as! NSBatchUpdateResult
            return batchResult.result as? Int
        } catch let error {
            print("Can't update in batch", error)
            return nil
        }
        
    }
    
    /**
     - Try not to use this when object has any kind of relationships with other entity.
     */
    @discardableResult
    func batchDeleteWithCount<M>(_ type : M.Type) -> Int? where M : NSManagedObject {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchDeleteRequest.resultType = .resultTypeCount
        batchDeleteRequest.affectedStores = context.persistentStoreCoordinator?.persistentStores
        
        do {
            let batchResult = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
            return batchResult.result as? Int
        } catch let error {
            print("Can't delete in batch", error)
            return nil
        }
        
    }
    
    
    @discardableResult
    func batchInsertWithCount<M>(_ type : M.Type, objects : [Dictionary<String,Any>]) -> Int? where M : NSManagedObject {
        
        let batchInsert = NSBatchInsertRequest(entityName: String(describing: type), objects: objects)
        batchInsert.resultType = .count
        batchInsert.affectedStores = context.persistentStoreCoordinator?.persistentStores
        do {
            let batchResult = try context.execute(batchInsert) as! NSBatchInsertResult
            return batchResult.result as? Int
        } catch let error {
            print("Can't insert in batch", error)
            return nil
        }
        
    }
    
}

public extension NSManagedObjectContext {
    
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    func executeDeleteAndMergeChanges<M>(_ type : M.Type) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}


//MARK:- For Database CRUD Operations
public extension CoreDataStack {
    
    
     func total<M>(_ type: M.Type) -> Int where M : NSManagedObject {
        
        do {
            return try context.count(for: M.fetchRequest())
        } catch let error {
            print("Error executing total: \(error)")
        }
        return 0
    }
    
    
    func fetch<M>(_ type: M.Type, predicate: NSPredicate? = nil, sortUsing: [(key : String, ascending : Bool)] = []) -> [M]? where M : NSManagedObject {
        
        let request = NSFetchRequest<M>(entityName: String(describing: type))
        request.predicate = predicate
        let sortDescriptors = sortUsing.map { NSSortDescriptor(key: $0.0, ascending: $0.1) }
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        }
        catch {
            print("Error executing fetch: \(error)")
        }
        return nil
    }
    
    
    func fetchAsync<M>(_ type: M.Type, predicate: NSPredicate? = nil, sortUsing: [(key : String, ascending : Bool)] = [], completed : @escaping (([M]?)->())) where M : NSManagedObject {

        let request = NSFetchRequest<M>(entityName: String(describing: type))
        request.predicate = predicate
        let sortDescriptors = sortUsing.map { NSSortDescriptor(key: $0.0, ascending: $0.1) }
        request.sortDescriptors = sortDescriptors
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: request) { (results) in
            guard let values = results.finalResult else { return completed(nil) }
            completed(values)
        }
        
        do {
            try context.execute(asyncFetch)
        } catch let error {
            print("Something went wrong while fetching data asynchronously", error)
        }
        
    }
    
    /**
    return type is [NSDictionary] so keep that in mind.
    */
    func fetchFew<M>(_ type: M.Type, propertiesToFetch : [Any], predicate: NSPredicate? = nil, sortUsing: [(key : String, ascending : Bool)] = []) -> Any? where M : NSManagedObject {
        
        let request = NSFetchRequest<NSDictionary>(entityName: String(describing: type))
        request.predicate = predicate
        request.propertiesToFetch = propertiesToFetch
        
        request.resultType = .dictionaryResultType
        let sortDescriptors = sortUsing.map { NSSortDescriptor(key: $0.0, ascending: $0.1) }
        request.sortDescriptors = sortDescriptors
        
        do {
            let result = try context.fetch(request)
            return result
        }
        catch {
            print("Error executing fetch: \(error)")
        }
        return nil
    }
    
    /**
     return type is [NSDictionary] so keep that in mind.
     */
    func fetchAsyncFew<M>(_ type: M.Type, propertiesToFetch : [Any], predicate: NSPredicate? = nil, sortUsing: [(key : String, ascending : Bool)] = [], completed : @escaping ((Any?)->())) -> Any? where M : NSManagedObject {
        
        let request = NSFetchRequest<NSDictionary>(entityName: String(describing: type))
        request.predicate = predicate
        request.propertiesToFetch = propertiesToFetch
        
        request.resultType = .dictionaryResultType
        let sortDescriptors = sortUsing.map { NSSortDescriptor(key: $0.0, ascending: $0.1) }
        request.sortDescriptors = sortDescriptors
        
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: request) { (results) in
            guard let values = results.finalResult else { return completed(nil) }
            completed(values)
        }
        
        do {
            let result = try context.execute(asyncFetch)
            return result
        }
        catch {
            print("Error executing fetch: \(error)")
        }
        return nil
    }
    
    
    func getStatisticsFromDB<M>(_ type: M.Type, mathOperation : MathOperations, resultType : NSAttributeType) -> Any? where M : NSManagedObject {
        
        let request = NSFetchRequest<NSDictionary>(entityName: String(describing: type))
        request.resultType = .dictionaryResultType
        
        let expression = NSExpressionDescription()
        expression.name = "Result"
        expression.expressionResultType = resultType
        
        switch mathOperation {
        case let .addto(from, to):
            let fromExpression = NSExpression(forKeyPath: from)
            let toExpression = NSExpression(forKeyPath: to)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [fromExpression,toExpression])
        case let .multiplyBy(from, to):
            let fromExpression = NSExpression(forKeyPath: from)
            let toExpression = NSExpression(forKeyPath: to)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [fromExpression,toExpression])
        case let .divideBy(from, to):
            let fromExpression = NSExpression(forKeyPath: from)
            let toExpression = NSExpression(forKeyPath: to)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [fromExpression,toExpression])
        case let .modulusBy(from, to):
            let fromExpression = NSExpression(forKeyPath: from)
            let toExpression = NSExpression(forKeyPath: to)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [fromExpression,toExpression])
        case let .subtractFrom(from, to):
            let fromExpression = NSExpression(forKeyPath: from)
            let toExpression = NSExpression(forKeyPath: to)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [fromExpression,toExpression])
        case let .sum(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        case let .count(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        case let .min(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        case let .max(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        case let .average(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        case let .length(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        case let .abs(key):
            let exp = NSExpression(forKeyPath: key)
            expression.expression = NSExpression(forFunction: mathOperation.functionName, arguments: [exp])
        }
        
        request.propertiesToFetch = [expression]
        
        do {
            let result = try context.fetch(request)
            return result.compactMap { $0.allValues }.reduce([], +)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    
    func add<M>(_ type: M.Type) -> M? where M : NSManagedObject {
        
        var modelObject = M()
        
        if let entity = NSEntityDescription.entity(forEntityName: String(describing: type), in: context) {
            modelObject = M(entity: entity, insertInto: context)
        }

        return modelObject
    }
    
    
    func delete(by objectID: NSManagedObjectID) {
        
        let managedObject = context.object(with: objectID)
        context.delete(managedObject)
        
    }
    
    
    func delete<M>(_ type: M.Type, predicate: NSPredicate? = nil) where M : NSManagedObject {
        
        if let objects = fetch(type, predicate: predicate) {
            for modelObject in objects {
                delete(by: modelObject.objectID)
            }
        }
        
        if context.deletedObjects.count > 0 {
            save()
        }
    }
    
    func clearSQLDatabase() {
        
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            print("Attempted to clear persistent store: " + error.localizedDescription)
        }
    }
    
}

@objc(CoreDataUIColorTransformer)
public final class CoreDataUIColorTransformer: ValueTransformer {
    
    static let name = NSValueTransformerName(rawValue: String(describing: CoreDataUIColorTransformer.self))
    
    public override class func transformedValueClass() -> AnyClass {
        UIColor.self
    }
    
    public override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform `UIColor` to `Data`")
            return nil
        }
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
            return color
        } catch {
            assertionFailure("Failed to transform `Data` to `UIColor`")
            return nil
        }
    }
    
    public static func register() {
        let transformer = CoreDataUIColorTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
    
}

@objc(CoreDataURLTransformer)
public final class CoreDataURLTransformer: ValueTransformer {

    static let name = NSValueTransformerName(rawValue: String(describing: CoreDataURLTransformer.self))
    
    override public class func transformedValueClass() -> AnyClass {
        NSURL.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        true
    }

    /// - Returns: An relative URL by removing the App Group URL if it exists in the URL.
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let url = value as? NSURL else { return nil }
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: url, requiringSecureCoding: true)
        } catch {
            assertionFailure("Failed to transform a `NSURL` to a relative version")
            return nil
        }
    }

    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        do {
            guard let data = value as? NSData, !data.isEmpty, let url = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSURL.self, from: data as Data) else { return nil }
            return url.absoluteURL
        } catch {
            assertionFailure("Failed to transform `Data` to `NSURL`")
            return nil
        }
    }
    
    public static func register() {
        let transformer = CoreDataURLTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }

}


//MARK:- Useful for JSON parsing
public extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

public extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}



/* Batch insert example starting from iOS14
 
 
 static func insertSamplesInBatch(_ numberOfSamples: Int) throws {
     let taskContext = PersistentContainer.shared.newBackgroundContext()
     taskContext.perform {
         do {
             let creationDate = Date()

             var index = 0

             let insertRequest = NSBatchInsertRequest(entity: entity(), managedObjectHandler: { object -> Bool in
 
                 if index == numberOfSamples { return true }
 
                 let article = object as! Article
                 article.name = String(format: "Generated %05d", index)
                 article.creationDate = creationDate
                 article.lastModifiedDate = creationDate
                 article.source = .generated
                 article.views = Int.random(in: 0..<1000)
                 index += 1
                 return false
             })
             try taskContext.execute(insertRequest)
             
             try taskContext.save()

             print("### \(#function): Batch inserted \(numberOfSamples) posts")
         } catch {
             print("### \(#function): Failed to insert articles in batch: \(error)")
         }
     }
 }
 */
