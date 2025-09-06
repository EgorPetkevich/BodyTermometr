//
//  TemperatureInputView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TemperatureInputView: UIView, UITextFieldDelegate {
    
    // MARK: - Private properties
    private let temperatureTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 48, weight: .regular)
        textField.textColor = .appBlack
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        textField.tintColor = .appBlack
        return textField
    }()
    
    private let bag = DisposeBag()
    private let temperatureSubject = BehaviorSubject<Double?>(value: nil)
    
    var unit: TempUnit = .c {
        didSet {
            convertDisplayedValue(from: oldValue, to: unit)
            updatePlaceholder(for: unit)
        }
    }
    
    var temperature: Observable<Double?> {
        temperatureSubject.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(temperatureTextField)
        temperatureTextField.delegate = self
        temperatureTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updatePlaceholder(for: unit)
        
        temperatureTextField.rx.text
            .map { [weak self] in self?.parseTemperature($0) }
            .bind(to: temperatureSubject)
            .disposed(by: bag)
    }

    private func updatePlaceholder(for unit: TempUnit) {
        switch unit {
        case .c:
            temperatureTextField.placeholder = "36,6"
            
        case .f:
            temperatureTextField.placeholder = "97,9"
            
        }
    }
    
    private func parseTemperature(_ text: String?) -> Double? {
        guard let t = text, !t.isEmpty else { return nil }
        let normalized = t.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
    
    private func formatTemperature(
        _ value: Double,
        for unit: TempUnit
    ) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 1
        return nf.string(
            from: NSNumber(value: value)) ?? String(format: "%.1f", value)
    }
    
    private func convertDisplayedValue(
        from oldUnit: TempUnit,
        to newUnit: TempUnit
    ) {
        guard
            let value = parseTemperature(temperatureTextField.text)
        else { return }
        let converted: Double
        switch (oldUnit, newUnit) {
        case (.c, .f):
            converted = value * 9.0/5.0 + 32.0
        case (.f, .c):
            converted = (value - 32.0) * 5.0/9.0
        default:
            converted = value
        }
        temperatureTextField.text = formatTemperature(converted, for: newUnit)
       
        temperatureSubject.onNext(converted)
    }
    
    // MARK: - UITextFieldDelegate
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let current = textField.text as NSString? else { return true }
        let newString = current.replacingCharacters(in: range, with: string)
        if newString.count > 5 { return false }
        let allowed = CharacterSet(charactersIn: "0123456789.,")
        if string.rangeOfCharacter(from: allowed.inverted) != nil { return false }
        let separators = newString.filter { $0 == "." || $0 == "," }
        if separators.count > 1 { return false }
        return true
    }
}
