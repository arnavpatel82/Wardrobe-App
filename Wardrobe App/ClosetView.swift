import SwiftUI

// Data Model for Category
struct Category: Identifiable, Codable {
    var id = UUID()
    var name: String
    var imageName: String
    var itemCount: Int
}

// Closet View
struct ClosetView: View {
    @State private var categories: [Category] = []
    @State private var clothingItems: [ClothingItem] = []
    @State private var isEditing = false
    @State private var newCategoryName = ""
    @State private var showingAddItem = false
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationView {
            VStack {
                if isEditing {
                    TextField("New Category Name", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button("Add Category") {
                        let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            categories.append(Category(name: trimmed, imageName: "hanger", itemCount: 0))
                            newCategoryName = ""
                        }
                    }
                    .padding(.bottom)
                }

                List {
                    ForEach(categories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category, items: $clothingItems)) {
                            HStack {
                                Image(category.imageName)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                                VStack(alignment: .leading) {
                                    Text(category.name)
                                        .font(.headline)
                                    Text("\(itemsInCategory(category.name).count) items")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        categories.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
            .onAppear {
                loadCategories()
                loadClothingItems()
            }
        }
    }

    private func itemsInCategory(_ categoryName: String) -> [ClothingItem] {
        clothingItems.filter { $0.category == categoryName }
    }

    func loadCategories() {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Category].self, from: data) else {
            return
        }
        categories = decoded
    }

    func loadClothingItems() {
        // TODO: Load from UserDefaults or local storage
    }

    func saveClothingItems() {
        // TODO: Save to UserDefaults or local storage
    }
}

struct CategoryDetailView: View {
    let category: Category
    @Binding var items: [ClothingItem]
    @State private var showingAddItem = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var categoryItems: [ClothingItem] {
        items.filter { $0.category == category.name }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categoryItems) { item in
                    if let image = item.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                Button(action: {
                                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                                        items.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .padding(8),
                                alignment: .topTrailing
                            )
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddClothingItemView(items: $items, category: category.name)
        }
    }
}

#Preview {
    ClosetView()
}
