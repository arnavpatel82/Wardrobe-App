import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WardrobeModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Category Operations
    
    func saveCategory(name: String) {
        let category = Category(context: viewContext)
        category.id = UUID()
        category.name = name
        saveContext()
    }
    
    func loadCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error loading categories: \(error)")
            return []
        }
    }
    
    func deleteCategory(_ category: Category) {
        viewContext.delete(category)
        saveContext()
    }
    
    // MARK: - Clothing Item Operations
    
    func saveClothingItem(category: Category, image: UIImage) {
        let item = ClothingItem(context: viewContext)
        item.id = UUID()
        item.category = category
        item.image = image.jpegData(compressionQuality: 0.8)
        saveContext()
    }
    
    func loadClothingItems(forCategory category: Category) -> [ClothingItem] {
        let request: NSFetchRequest<ClothingItem> = ClothingItem.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ClothingItem.id, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error loading clothing items: \(error)")
            return []
        }
    }
    
    func deleteClothingItem(_ item: ClothingItem) {
        viewContext.delete(item)
        saveContext()
    }
    
    // MARK: - Outfit Operations
    
    func saveOutfit(name: String, items: [ClothingItem], image: UIImage? = nil) {
        let outfit = Outfit(context: viewContext)
        outfit.id = UUID()
        outfit.name = name
        outfit.image = image?.jpegData(compressionQuality: 0.8)
        outfit.items = NSSet(array: items)
        saveContext()
    }
    
    func loadOutfits() -> [Outfit] {
        let request: NSFetchRequest<Outfit> = Outfit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Outfit.name, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error loading outfits: \(error)")
            return []
        }
    }
    
    func deleteOutfit(_ outfit: Outfit) {
        viewContext.delete(outfit)
        saveContext()
    }
    
    // MARK: - Context Operations
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Preview Helper
    
    static var preview: CoreDataManager = {
        let manager = CoreDataManager()
        let viewContext = manager.persistentContainer.viewContext
        
        // Create sample categories
        let topsCategory = Category(context: viewContext)
        topsCategory.id = UUID()
        topsCategory.name = "Tops"
        
        let bottomsCategory = Category(context: viewContext)
        bottomsCategory.id = UUID()
        bottomsCategory.name = "Bottoms"
        
        // Create sample clothing items
        let shirt = ClothingItem(context: viewContext)
        shirt.id = UUID()
        shirt.category = topsCategory
        shirt.image = UIImage(systemName: "tshirt")?.jpegData(compressionQuality: 0.8)
        
        let pants = ClothingItem(context: viewContext)
        pants.id = UUID()
        pants.category = bottomsCategory
        pants.image = UIImage(systemName: "pants")?.jpegData(compressionQuality: 0.8)
        
        // Create sample outfit
        let outfit = Outfit(context: viewContext)
        outfit.id = UUID()
        outfit.name = "Casual Look"
        outfit.items = NSSet(array: [shirt, pants])
        
        try? viewContext.save()
        return manager
    }()
} 