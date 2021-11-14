//
//  ContentView.swift
//  SwiftUISlideSorter
//
//  Created by TR Solutions on 5/11/21.
//

import SwiftUI
import CoreData
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Slide.sortOrder, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Slide>
  
  var body: some View {
    // Temporary hack to get to the point where
    // there is at least one row of data
    if items.count < 3 {
      Text("Hello this is a very long piece of text to make the window big enough")
        .toolbar {
          ToolbarItem {
            Button(action: addItem) {
              Label("Add Slide", systemImage: "plus")
            }
          }
        }
    } else {
      VStack(spacing: 20) {
        let slideRowIndices = 0..<(items.count / 3)
        ForEach(slideRowIndices) { rowIndex in
          HStack(spacing: 20) {
            let slideColumnIndices = 0..<3
            ForEach(slideColumnIndices) { columnIndex in
              let itemIndex = rowIndex*3+columnIndex
              if itemIndex < items.count {
                let image = NSImage(data:items[itemIndex].picture!)!
                Image(nsImage: image)
                  .onDrag {
                    let itemProvider: NSItemProvider = NSItemProvider(object: NSString(format: "%d", itemIndex))
                    print("on drag, item provider = \(itemProvider)")
                    print("  readable type identifiers = \(itemProvider.registeredTypeIdentifiers)")
                    return itemProvider
                  }
                // This way does the changes outside the view, which can be messy.
                // .onDrop(of: [.text], delegate: DragRelocateDelegate(dropPosition: itemIndex))
                //
                // This way makes the changes inside the view
                  .onDrop(of: [UTType.utf8PlainText], isTargeted: nil) { providers in
                     print("Dropping providers \(providers)")
                     if let firstItemProvider = providers.first {
                       print("  identifiers: \(firstItemProvider.registeredTypeIdentifiers)")
                       firstItemProvider.loadObject(ofClass: NSString.self) { data, error in
                         print("load object got data \(String(describing: data)), error \(String(describing: error))")
                         if let string = data as? NSString {
                           if let sourceIndex = Int(string as String) {
                             print("Moving slide from \(sourceIndex) to \(itemIndex)")
                           }
                         }
                       }
                     }
                     return true
                 }
              } else {
                Spacer()
              }
            }
          }
        }
      }
      .background(Color.white)
      //    NavigationView {
      //      List {
      //        ForEach(items) { item in
      //          NavigationLink {
      //            Text("Slide at \(item.timestamp!, formatter: itemFormatter)")
      //          } label: {
      //            Text(item.timestamp!, formatter: itemFormatter)
      //          }
      //        }
      //        .onDelete(perform: deleteItems)
      //      }
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Slide", systemImage: "plus")
          }
        }
      }
    }
  }
  
  private func addItem() {
    let fetchRequest: NSFetchRequest<Slide> = NSFetchRequest(entityName: "Slide")
    var count = 0;
    viewContext.performAndWait {
      do {
        count = try viewContext.count(for: fetchRequest)
      } catch {
        count = 0
      }
    }
    withAnimation {
      let newItem = Slide(context: viewContext)
      let nextPictureNumber:Int = count
      let nsImage: NSImage;
      switch nextPictureNumber {
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
      newItem.sortOrder = Float(nextPictureNumber)
      newItem.picture = nsImage.tiffRepresentation
      newItem.timestamp = Date()
      
      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { items[$0] }.forEach(viewContext.delete)
      
      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

struct DragRelocateDelegate: DropDelegate {
  let dropPosition: Int
  func dropEntered(info: DropInfo) {
    // print("In drop entered, position = \(dropPosition), info \(info)")
  }
  func dropUpdated(info: DropInfo) -> DropProposal? {
    return DropProposal(operation: .move)
  }
  func performDrop(info: DropInfo) -> Bool {
    print("in perform Drop, position = \(dropPosition), info: \(info)")
    // let itemProviderArray = info.itemProviders(for: [.text])
    let itemProviderArray = info.itemProviders(for: ["public.utf8-plain-text"])
    print("  \(itemProviderArray.count) item providers found.")
    if let firstItemProvider = itemProviderArray.first {
      print("  identifiers: \(firstItemProvider.registeredTypeIdentifiers)")
      firstItemProvider.loadObject(ofClass: NSString.self) { data, error in
        print("load object got data \(String(describing: data)), error \(String(describing: error))")
        if let string = data as? NSString {
          if let sourceIndex = Int(string as String) {
            print("Moving slide from \(sourceIndex) to \(dropPosition)")
          }
        }
      }
    }
    return true
  }
  private func onDataExtracted() {
    
  }
  
}
private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
