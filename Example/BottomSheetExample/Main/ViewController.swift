//
//  ViewController.swift
//  BottomSheetExample
//
//  Created by Gaetano Matonti on 22/11/20.
//

import UIKit
import BottomSheet

final class ViewController: UIViewController {
  
  private let viewModel = ViewModel()
  private let mainView = View()
  
  override func loadView() {
    super.loadView()
    
    view = mainView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mainView.populateSegmentedControl(picker: \.sheetSizingStylePicker, with: viewModel.sheetSizingItems)
    mainView.populateSegmentedControl(picker: \.handleStylePicker, with: viewModel.handleStyleItems)
    mainView.populateSegmentedControl(picker: \.exampleTypePicker, with: viewModel.exampleTypesItems)
    
    mainView.button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
    mainView.sheetSizingStylePicker.addTarget(self, action: #selector(didSelectSegmentedItem), for: .valueChanged)
    mainView.handleStylePicker.addTarget(self, action: #selector(didSelectSegmentedItem), for: .valueChanged)
    mainView.exampleTypePicker.addTarget(self, action: #selector(didSelectSegmentedItem), for: .valueChanged)
  }
  
  @objc private func didPressButton(_ sender: UIButton) {
    let controller = BottomSheetViewController()
    
    switch viewModel.selectedExampleType {
      case .content:
        controller.contentInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        controller.contentView = ExampleBottomSheetView()
      case .list:
        controller.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        controller.addChildContent(TableViewExampleController())
    }
    
    controller.sheetCornerRadius = 32
    controller.sheetSizingStyle = viewModel.selectedSheetSizingStyle
    controller.handleStyle = viewModel.selectedHandleStyle
    present(controller, animated: true, completion: nil)
  }
  
  @objc func didSelectSegmentedItem(_ sender: UISegmentedControl) {
    if sender === mainView.sheetSizingStylePicker {
      viewModel.selectedSheetSizingStyle = viewModel.sheetSizingItems[mainView.sheetSizingStylePicker.selectedSegmentIndex].style
      return
    }
    if sender === mainView.handleStylePicker {
      viewModel.selectedHandleStyle = viewModel.handleStyleItems[mainView.handleStylePicker.selectedSegmentIndex].style
      return
    }
    if sender === mainView.exampleTypePicker {
      viewModel.selectedExampleType = viewModel.exampleTypesItems[mainView.exampleTypePicker.selectedSegmentIndex].exampleType
      return
    }
  }
}
