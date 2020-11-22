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
        
        mainView.button.addAction(UIAction(handler: didPressButton), for: .touchUpInside)
        
        let pickerAction = UIAction(handler: didSelectSegmentedItem)
        mainView.pickers.forEach {
            $0.addAction(pickerAction, for: .valueChanged)
        }
    }
    
    private func didPressButton(_ action: UIAction) {
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
    
    func didSelectSegmentedItem(_ action: UIAction) {
        guard let sender = action.sender as? UISegmentedControl else { return }
        
        switch sender {
            case mainView.sheetSizingStylePicker:
                viewModel.selectedSheetSizingStyle = viewModel.sheetSizingItems[mainView.sheetSizingStylePicker.selectedSegmentIndex].style
            case mainView.handleStylePicker:
                viewModel.selectedHandleStyle = viewModel.handleStyleItems[mainView.handleStylePicker.selectedSegmentIndex].style
            case mainView.exampleTypePicker:
                viewModel.selectedExampleType = viewModel.exampleTypesItems[mainView.exampleTypePicker.selectedSegmentIndex].exampleType
            default:
                break
        }
    }
    
}
