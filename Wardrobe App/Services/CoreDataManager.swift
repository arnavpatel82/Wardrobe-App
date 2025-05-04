import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    
    // Add a preview context for SwiftUI previews
    static var preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        return manager
    }()
    
    // Add a preview context property
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WardrobeModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Categories
    
    func loadCategories() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: "Category")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func saveCategory(name: String) {
        let category = Category(context: container.viewContext)
        category.name = name
        
        saveContext()
    }
    
    func deleteCategory(_ category: Category) {
        container.viewContext.delete(category)
        saveContext()
    }
    
    // MARK: - Clothing Items
    
    func saveClothingItem(category: Category, image: UIImage) {
        let item = ClothingItem(context: container.viewContext)
        item.id = UUID()
        item.dateAdded = Date()
        item.category = category
        
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            item.imageData = imageData
        }
        
        saveContext()
    }
    
    func loadClothingItems(forCategory category: Category) -> [ClothingItem] {
        let request = NSFetchRequest<ClothingItem>(entityName: "ClothingItem")
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ClothingItem.dateAdded, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
    
    func deleteClothingItem(_ item: ClothingItem) {
        container.viewContext.delete(item)
        saveContext()
    }
    
    // MARK: - Context
    
    private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
} 