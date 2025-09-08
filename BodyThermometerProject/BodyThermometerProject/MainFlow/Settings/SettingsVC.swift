//
//  SettingsVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 24.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol SettingsViewModelProtocol {
    // Out
    var items: Observable<[SettingsSection.Settings]> { get }
    var isPremium: Driver<Bool> { get }
    // In
    var closeTapped: PublishSubject<Void> { get }
    var upgradeButtonDidTap: PublishSubject<Void> { get }
    func didSelect(_ item: SettingsSection.Settings)
}

final class SettingsVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Settings"
        static let closeButtonText: String = "Close"
    }
    
    private enum LayoutConst {
        static let rowHeight: CGFloat = 60.0
        static let tableViewRadius: CGFloat = 24.0
    }
    
    private var tableViewTopConstraint: Constraint?
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var closeButton: UIButton =
    UIButton(type: .system)
        .setTitle(TextConst.closeButtonText)
        .setTintColor(.appGrey)
    
    private lazy var goPremiumButton: SettingsGoPremiumView =
    SettingsGoPremiumView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(SettingsRow.self)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = LayoutConst.rowHeight
        tableView.separatorColor = .clear
        tableView.radius = LayoutConst.tableViewRadius
        return tableView
    }()
    
    private var viewModel: SettingsViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBg
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func bind() {
        viewModel.isPremium
            .drive(onNext: { [weak self] isPremium in
                self?.tableViewTopConstraint?
                    .update(inset: isPremium ? 91.0 : 189.0)
                self?.goPremiumButton.isHidden = isPremium
            })
            .disposed(by: bag)
        viewModel.items
            .bind(to: tableView.rx.items(
                cellIdentifier: "\(SettingsRow.self)",
                cellType: SettingsRow.self
            )) { _, item, cell in
                cell.configure(item)
            }
            .disposed(by: bag)
        goPremiumButton.tap
            .bind(to: viewModel.upgradeButtonDidTap)
            .disposed(by: bag)

        tableView.rx.modelSelected(SettingsSection.Settings.self)
            .subscribe(onNext: { [weak self] item in
                self?.viewModel.didSelect(item)
            })
            .disposed(by: bag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)
        
        closeButton.rx.tap
            .bind(to: viewModel.closeTapped)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension SettingsVC {
    
    func commonInit() {
        view.backgroundColor = .appBg
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(goPremiumButton)
        view.addSubview(tableView)
    }
    
    func setupSnapKitConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(38.0)
        }
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(24.0)
        }
        goPremiumButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.height.equalTo(360)
            tableViewTopConstraint = make.top.equalToSuperview().inset(189.0).constraint
        }
    }
    
}
