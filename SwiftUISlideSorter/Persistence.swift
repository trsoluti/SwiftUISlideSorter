//
//  Persistence.swift
//  SwiftUISlideSorter
//
//  Created by TR Solutions on 5/11/21.
//

import CoreData
import AppKit

struct PersistenceController {
  static let shared = PersistenceController()
  
  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    for index in 0..<6 {
      let newItem = Slide(context: viewContext)
      let nsImage: NSImage;
      switch index {
      case 0:
        nsImage = NSImage(imageLiteralResourceName: "letter-a")
      case 1:
        nsImage = NSImage(imageLiteralResourceName: "letter-c")
      case 2:
        nsImage = NSImage(imageLiteralResourceName: "letter-e")
      case 3:
        nsImage = NSImage(imageLiteralResourceName: "letter-p")
      case 4:
        nsImage = NSImage(imageLiteralResourceName: "letter-r")
      default:
        nsImage = NSImage(imageLiteralResourceName: "letter-s")
      }
      newItem.sortOrder = Float(index)
      newItem.picture = nsImage.tiffRepresentation
      newItem.timestamp = Date()
    }
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()
  
  let container: NSPersistentContainer
  
  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "SwiftUISlideSorter")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }
}
