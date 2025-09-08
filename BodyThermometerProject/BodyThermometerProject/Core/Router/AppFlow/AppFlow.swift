//
//  AppFlow.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import RxSwift
import RxCocoa


final class AppFlow {
    
    let didFinishOnboarding = PublishRelay<Void>()
    let didFinishPaywall = PublishRelay<Void>()
    let didFinishRegistration = PublishRelay<Void>()
   
}
