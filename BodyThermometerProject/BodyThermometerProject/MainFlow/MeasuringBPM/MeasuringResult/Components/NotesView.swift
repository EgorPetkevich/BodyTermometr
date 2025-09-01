//
//  NotesView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class NotesView: UIView {
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
    }
    
    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)

    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .appRegularFont(ofSize: 15)
        tf.returnKeyType = .done
        tf.backgroundColor = .clear
        tf.attributedPlaceholder = NSAttributedString(
            string: "Add notes...",
            attributes: [.foregroundColor: UIColor.appLightGrey]
        )
        tf.textColor = .appWhite
        return tf
    }()
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private let bag = DisposeBag()
    private let doneSubject = PublishSubject<String>()
    
    var textObservable: Observable<String>
    { textField.rx.text.orEmpty.asObservable() }
    
    var doneText: Observable<String> { doneSubject.asObservable() }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapkitConstraints()
        bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        setupSnapkitConstraints()
        bind()
    }

    private func bind() {
        textField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(textField.rx.text.orEmpty)
            .bind(onNext: { [weak self] text in
                self?.endEditing(true)
                self?.isHidden = true
                self?.doneSubject.onNext(text)
            })
            .disposed(by: bag)

        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        tap.rx.event
            .bind(onNext: { [weak self] _ in self?.endEditing(true) })
            .disposed(by: bag)
        
        crossButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                self?.endEditing(true)
                self?.isHidden = true
                self?.doneSubject.onNext(text)
        })
        .disposed(by: bag)
    }

    func show(prefill text: String? = nil) {
        textField.text = text
        isHidden = false
        textField.becomeFirstResponder()
    }

    func hide() {
        endEditing(true)
        isHidden = true
    }
}

//MARK: - Private
private extension NotesView {
    
    func commonInit() {
        isHidden = true
        addSubview(blurView)
        addSubview(textField)
        addSubview(crossButton)
    }
    
    func setupSnapkitConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(295)
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.height.equalTo(56.0)
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        crossButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(62.0)
            make.size.equalTo(LayoutConst.crossButtonSize)
        }
        crossButton.radius = LayoutConst.crossButtonSize / 2
    }
    
}
