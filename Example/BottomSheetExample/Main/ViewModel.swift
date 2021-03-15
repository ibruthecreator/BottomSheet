//
//  ViewModel.swift
//  BottomSheetExample
//
//  Created by Gaetano Matonti on 22/11/20.
//

import BottomSheet

protocol Item {
  var title: String { get }
}

enum ExampleType {
    case content, list
}

final class ViewModel {
  struct SheetSizingItem: Item {
    let style: BottomSheetView.SheetSizingStyle
    let title: String
  }
  
  struct HandleStyle: Item {
    let style: BottomSheetView.HandleStyle
    let title: String
  }
  
  struct ExampleItem: Item {
      let exampleType: ExampleType
      let title: String
  }

  let sheetSizingItems: [SheetSizingItem] = [
    .init(style: .adaptive, title: "Adaptive"),
    .init(style: .fixed(height: 480), title: "Fixed"),
    .init(style: .toSafeAreaTop, title: "Safe Area")
  ]
    
  let handleStyleItems: [HandleStyle] = [
    .init(style: .none, title: "None"),
    .init(style: .inside, title: "Inside"),
    .init(style: .outside, title: "Outside")
  ]
  
  let exampleTypesItems: [ExampleItem] = [
      .init(exampleType: .content, title: "Content"),
      .init(exampleType: .list, title: "List")
  ]
  
  var selectedSheetSizingStyle: BottomSheetView.SheetSizingStyle = .adaptive

  var selectedHandleStyle: BottomSheetView.HandleStyle = .none
  
  var selectedExampleType: ExampleType = .content
}
