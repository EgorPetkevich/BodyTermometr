//
//  ApphudService.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 7.09.25.
//

import Foundation
import RxSwift
import RxCocoa
import ApphudSDK


final class ApphudRxManager {

    static let instanse = ApphudRxManager()
    private init() {}

    private let bag = DisposeBag()

    // MARK: - Relays
    let configRelay = BehaviorRelay<RemoteConfig>(value: RemoteConfig())
    let paywallProdRelay = BehaviorRelay<[PaywallProduct]>(value: [])
    let paywallIdRelay = BehaviorRelay<PaywallId>(value: .onboarding)
    let isActiveRelay = BehaviorRelay<Bool>(value: true)

    // MARK: - Public
    
    func start() -> Completable {
        Completable.create { completable in
            Task { @MainActor in
                Apphud.start(apiKey: AppConfig.Apphud.apiKey)
            }
          
            completable(.completed)
            return Disposables.create()
        }
    }

    func hasActiveSubscription() -> Single<Bool> {
        Single.just(Apphud.hasActiveSubscription())
            .do(onSuccess: { [weak self] active in
                self?.isActiveRelay.accept(active)
            })
    }

    func loadPaywall(for identifier: PaywallId) -> Completable {
        paywallIdRelay.accept(identifier)

        return fetchPaywalls()
            .map { paywalls -> ApphudPaywall? in
                paywalls.first { $0.identifier == identifier.rawValue }
            }
            .flatMapCompletable { [weak self] paywall in
                guard let self, let paywall else { return .empty() }
                return self.decode(paywall: paywall)
            }
    }
    
    func purchase(_ product: ApphudProduct) -> Single<ApphudSubscription> {
        Single<ApphudSubscription>.create { [weak self] single in
            Task { @MainActor in
                Apphud.purchase(product) { result in
                    if let sub = result.subscription, sub.isActive() {
                        self?.isActiveRelay.accept(true)
                        single(.success(sub))
                    } else if let error = result.error {
                        single(.failure(error))
                    } else {
                        single(.failure(
                            NSError(domain: "Apphud", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result"]
                                   )
                        ))
                    }
                }
            }
            return Disposables.create()
        }
    }

    func restorePurchases() -> Single<Bool> {
        Single<Bool>.create { [weak self] single in
            Task { @MainActor in
                Apphud.restorePurchases { subscriptions, _, error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    let hasAny = (subscriptions?.isEmpty == false)
                    self?.isActiveRelay.accept(hasAny)
                    single(.success(hasAny))
                }
            }
            return Disposables.create()
        }
    }

    // MARK: - Helpers
    func isTrial() -> Bool {
        paywallProdRelay.value.contains { $0.id.lowercased().contains("trial") }
    }

    func product(for type: ProductType) -> PaywallProduct? {
        switch type {
        case .trial:
            return paywallProdRelay.value.first { $0.id.lowercased().contains("trial") }
        case .prod:
            return paywallProdRelay.value.first { !$0.id.lowercased().contains("trial") }
        }
    }

    // MARK: - Private
    private func fetchPaywalls() -> Single<[ApphudPaywall]> {
        Single<[ApphudPaywall]>.create { single in
            Task { @MainActor in
                Apphud.paywallsDidLoadCallback { paywalls, error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(paywalls))
                    }
                }
            }
            return Disposables.create()
        }
    }

    private func decode(paywall: ApphudPaywall) -> Completable {
        let productsSingle: Single<[PaywallProduct]> = makeProducts(from: paywall)

        let configSingle: Single<RemoteConfig> = Single<RemoteConfig>.create { single in
            if let json = paywall.json,
               let data = try? JSONSerialization.data(withJSONObject: json),
               let decoded = try? JSONDecoder().decode(RemoteConfig.self, from: data) {
                single(.success(decoded))
            } else {
                single(.success(RemoteConfig()))
            }
            return Disposables.create()
        }

        return Single.zip(productsSingle, configSingle)
            .do(onSuccess: { [weak self] products, config in
                self?.paywallProdRelay.accept(products)
                self?.configRelay.accept(config)
            })
            .asCompletable()
    }

    private func makeProducts(from paywall: ApphudPaywall) -> Single<[PaywallProduct]> {

        let singles = paywall.products.map { product in
            Single<PaywallProduct>.create { single in
                Task {
                    let pr = await PaywallProduct(from: product)
                    single(.success(pr))
                }
                return Disposables.create()
            }
        }
        return Single.zip(singles)
    }
}



