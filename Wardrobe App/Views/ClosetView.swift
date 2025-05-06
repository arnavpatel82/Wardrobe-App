import SwiftUI
import CoreData

struct ClosetView: View {
    @State private var categories: [Category] = []
    @State private var showingAddCategory = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var newCategoryName = ""
    @State private var categoryToDelete: Category?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                    ForEach(categories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category, onItemsChanged: loadCategories)) {
                            CategoryCard(category: category)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                categoryToDelete = category
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Category", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .alert("Add Category", isPresented: $showingAddCategory) {
                TextField("Category Name", text: $newCategoryName)
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
                Button("Add") {
                    if !newCategoryName.isEmpty {
                        CoreDataManager.shared.saveCategory(name: newCategoryName)
                        newCategoryName = ""
                        loadCategories()
                    }
                }
            }
            .alert("Delete Category", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    categoryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        CoreDataManager.shared.deleteCategory(category)
                        categoryToDelete = nil
                        loadCategories()
                    }
                }
            } message: {
                if let category = categoryToDelete {
                    Text("Are you sure you want to delete '\(category.name ?? "Unnamed")'? This will also delete all items in this category.")
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            loadCategories()
        }
    }
    
    private func loadCategories() {
        categories = CoreDataManager.shared.loadCategories()
    }
}

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack {
            Text(category.name ?? "Unnamed")
                .font(.headline)
            Text("\(category.items?.count ?? 0) items")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    ClosetView()
} 