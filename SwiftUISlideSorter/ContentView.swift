//
//  ContentView.swift
//  SwiftUISlideSorter
//
//  Created by TR Solutions on 5/11/21.
//

import SwiftUI
import CoreData
import AppKit

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Slide.sortOrder, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Slide>
  
  var body: some View {
      VStack(spacing: 20) {
        let slideRowIndices = 0..<(items.count / 3)
        ForEach(slideRowIndices) { rowIndex in
          HStack(spacing: 20) {
            let slideColumnIndices = 0..<3
            ForEach(slideColumnIndices) { columnIndex in
              let image = NSImage(data:items[rowIndex*3+columnIndex].picture!)!
              Image(nsImage: image)
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
  
  private func addItem() {
    withAnimation {
      let newItem = Slide(context: viewContext)
      let nextPictureNumber:Int = 0
      let nsImage: NSImage;
      switch nextPictureNumber {
      case 0:
        nsImage = NSImage(imageLiteralResourceName: "letter-a")
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
