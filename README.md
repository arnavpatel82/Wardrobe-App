# Wardrobe App

A modern iOS application that helps you organize and manage your clothing items, create outfits, and keep track of your wardrobe.

## Demo

[Watch Demo Video](Wardrobe%20App/Resources/demo.mp4)

## Features

- **Category Management**
  - Create and organize clothing items into categories
  - View items by category

- **Clothing Item Management**
  - Add clothing items with photos and descriptions
  - View items in a grid layout
  - Automatic background removal for clothing photos

- **Outfit Creation**
  - Create outfits by combining multiple clothing items
  - Search through your wardrobe while creating outfits
  - View all your created outfits

## Technical Details

- Built with SwiftUI and CoreData
- Uses Google's Cloud Vision API for image processing

## Getting Started

1. Clone the repository
2. Open `Wardrobe App.xcodeproj` in Xcode
3. Build and run the project

## Requirements

- Xcode 14.0 or later
- iOS 15.0 or later
- Swift 5.0 or later

## Project Structure

```
Wardrobe App/
├── Views/
│   ├── ClosetView.swift
│   ├── CategoryDetailView.swift
│   ├── AddClothingItemView.swift
│   ├── CreateOutfitView.swift
│   └── OutfitsView.swift
├── Models/
│   ├── Category.swift
│   ├── ClothingItem.swift
│   └── Outfit.swift
├── Utils/
│   └── CoreDataManager.swift
├── Services/
│   └── PhotoRoomService.swift
└── Resources/
    └── demo.mp4
```

## Core Features Implementation

### Category Management
- Categories are stored in CoreData
- Each category can contain multiple clothing items
- Categories are displayed in a grid layout with item counts

### Clothing Item Management
- Items are stored with photos and descriptions
- Photos are processed to remove backgrounds
- Items are organized by categories
- Grid layout for easy browsing

### Outfit Creation
- Create outfits by selecting multiple items
- Search functionality to find specific items
- Edit existing outfits
- View all outfits in a list

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- PhotoRoom API for background removal
- Google's Cloud Vision API for image processing
- CoreData for data persistence 
