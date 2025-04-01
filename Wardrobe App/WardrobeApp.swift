import SwiftUI

// Data Model for Category
struct Category: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
    var itemCount: Int
}

// Sample Data
var sampleCategories = [
    Category(name: "Sweaters", imageName: "sweater", itemCount: 9),
    Category(name: "Shirts", imageName: "shirt", itemCount: 5),
    Category(name: "Bottoms", imageName: "jeans", itemCount: 9),
    Category(name: "Shoes", imageName: "shoes", itemCount: 6),
    Category(name: "Accessories", imageName: "belt", itemCount: 3),
    Category(name: "Outerwear", imageName: "jacket", itemCount: 2),
    Category(name: "I Wish", imageName: "hanger", itemCount: 0)
]

// Closet View
struct ClosetView: View {
    @State private var categories = sampleCategories
    @State private var isEditing = false
    @State private var newCategoryName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isEditing {
                    TextField("New Category Name", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Add Category") {
                        if !newCategoryName.isEmpty {
                            let newCategory = Category(name: newCategoryName, imageName: "hanger", itemCount: 0)
                            categories.append(newCategory)
                            newCategoryName = ""
                        }
                    }
                    .padding()
                }
                
                List {
                    ForEach(categories) { category in
                        HStack {
                            Image(category.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                            VStack(alignment: .leading) {
                                Text(category.name)
                                    .font(.headline)
                                Text("\(category.itemCount) items")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        categories.remove(atOffsets: indexSet)
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
            }
        }
    }
}

#Preview {
    ClosetView()
}
